import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../service/settings_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class SettingsController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final Rx<dynamic> user = Rx<dynamic>(null);
  final RxMap<String, bool> preferences = <String, bool>{}.obs;
  final RxString errorMessage = ''.obs;

  final _logger = Logger();
  final _settingsService = SettingsService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  // ==================== Business Logic ====================
  void _loadUserData() {
    // TODO: Load user data and preferences
    preferences.value = {
      'notifications': true,
      'locationSharing': true,
      'soundEffects': true,
    };
  }

  void navigateToSetting(String settingType) {
    switch (settingType) {
      case 'changePassword':
        // Get.toNamed(AppRoutes.changePasswordScreen);
        break;
      case 'changeLanguage':
        // Get.toNamed(AppRoutes.changeLanguageScreen);
        break;
      case 'profile':
        // Navigate to profile based on user role
        break;
      default:
        break;
    }
  }

  void togglePreference(String key, bool value) {
    preferences[key] = value;
    // TODO: Save preference to storage/API
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // TODO: Implement logout API call
      await Future.delayed(const Duration(seconds: 1));

      // Clear user data and navigate to login
      // Get.offAllNamed(AppRoutes.loginScreen);

    } catch (e) {
      debugPrint('settings_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      _logger.i('Requesting account deletion...');

      final response = await _settingsService.deleteAccount();

      _logger.i('Delete account response — statusCode: ${response.statusCode}, isSuccess: ${response.isSuccess}');

      if (response.isSuccess) {
        _logger.i('Account deletion scheduled successfully');
        return true;
      } else {
        debugPrint('settings_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        _logger.e('Delete account failed — error: ${response.errorMessage}');
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFD32F2F),
          colorText: const Color(0xFFFFFFFF),
        );
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('settings_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      _logger.e('Exception during delete account', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(AppRoutes.loginScreen);
  }
}
