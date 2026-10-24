import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_urls.dart';
import 'socket_services.dart';
import 'package:ride_sharing/routes/app_routes.dart';

/// Single owner of credentials and the server-reported account state.
class SessionController extends GetxService {
  static SessionController get to => Get.find<SessionController>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _authClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  final RxnString accountState = RxnString();
  final RxList<String> roles = <String>[].obs;
  String? _accessToken;
  String? _refreshToken;
  Future<String?>? _refreshInFlight;

  Future<void> restore() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _refreshToken = await _storage.read(key: 'refreshToken');
    // One-time migration from the old unencrypted storage. Remove both keys
    // only after the secure write succeeds.
    final prefs = await SharedPreferences.getInstance();
    if (_refreshToken == null) {
      final oldAccess = prefs.getString('accessToken');
      final oldRefresh = prefs.getString('refreshToken');
      if (oldAccess != null && oldRefresh != null) {
        await saveTokens(oldAccess, oldRefresh);
      }
    }
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  Future<String?> accessToken() async =>
      _accessToken ??= await _storage.read(key: 'accessToken');

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'refreshToken', value: refresh);
    await _storage.write(key: 'accessToken', value: access);
    _accessToken = access;
    _refreshToken = refresh;
  }

  void updateFromErrorCode(String? code) {
    const states = <String, String>{
      'ONBOARDING_REQUIRED': 'NEEDS_ONBOARDING',
      'ACCOUNT_PENDING_REVIEW': 'PENDING_REVIEW',
      'ACCOUNT_REJECTED': 'REJECTED',
      'ACCOUNT_SUSPENDED': 'SUSPENDED',
      'ACCOUNT_DELETED': 'DELETED',
    };
    final state = states[code];
    if (state == null) return;
    accountState.value = state;
    if (Get.isRegistered<SocketIoService>()) SocketIoService.to.disconnect();
    Future<void>.microtask(() {
      if (Get.context == null || Get.currentRoute == AppRoutes.splashScreen)
        return;
      final destination = state == 'NEEDS_ONBOARDING'
          ? AppRoutes.driverRegistrationScreen
          : AppRoutes.accountStatusScreen;
      if (Get.currentRoute != destination) Get.offAllNamed(destination);
    });
  }

  Future<String?> refresh() => _refreshInFlight ??= _doRefresh().whenComplete(
    () => _refreshInFlight = null,
  );

  Future<String?> _doRefresh() async {
    final token = _refreshToken ?? await _storage.read(key: 'refreshToken');
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _authClient.post(
        ApiUrls.refresh,
        data: {'refreshToken': token},
      );
      final data = response.data['data'];
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (access == null || refresh == null)
        throw StateError('Invalid refresh response');
      await saveTokens(access, refresh);
      return access;
    } on DioException catch (error) {
      // A network failure does not invalidate the user's saved session.
      if (error.response?.statusCode == 400 ||
          error.response?.statusCode == 401) {
        await clear();
        if (Get.context != null && Get.currentRoute != AppRoutes.splashScreen) {
          Get.offAllNamed(AppRoutes.loginScreen);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> loadAccount() async {
    var token = await accessToken();
    if (token == null) token = await refresh();
    if (token == null) return false;
    try {
      var response = await _authClient.get(
        ApiUrls.me,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      accountState.value = data['accountState'] as String?;
      roles.assignAll(List<String>.from(data['user']?['role'] ?? []));
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        token = await refresh();
        if (token != null) {
          try {
            final response = await _authClient.get(
              ApiUrls.me,
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
            final data = response.data['data'] as Map<String, dynamic>;
            accountState.value = data['accountState'] as String?;
            roles.assignAll(List<String>.from(data['user']?['role'] ?? []));
            return true;
          } on DioException catch (retryError) {
            if (retryError.response?.statusCode == 401) await clear();
            return false;
          } catch (_) {
            return false;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    final token = _refreshToken ?? await _storage.read(key: 'refreshToken');
    if (token != null) {
      try {
        await _authClient.post(ApiUrls.logout, data: {'refreshToken': token});
      } catch (_) {
        /* local logout still succeeds */
      }
    }
    await clear();
  }

  Future<void> clear() async {
    if (Get.isRegistered<SocketIoService>()) SocketIoService.to.disconnect();
    _accessToken = null;
    _refreshToken = null;
    accountState.value = null;
    roles.clear();
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userRole');
    await prefs.remove('userId');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('profilePicture');
    await prefs.remove('needsVerification');
  }
}
