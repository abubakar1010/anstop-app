import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/fcm_service.dart';
import 'package:ride_sharing/services/locale_service.dart';

class SplashController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = true.obs;
  final RxBool isAuthenticated = false.obs;
  final RxList<String> userRoles = <String>[].obs;
  final RxBool isFrench = true.obs;

  // ==================== Services ====================
  final FcmService _fcmService = FcmService();
  final AuthService _authService = AuthService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    isFrench.value = LocaleService.isFrench;
    _initialize();
  }

  // ==================== UI Actions ====================
  Future<void> toggleLanguage(bool value) async {
    isFrench.value = value;
    await LocaleService.setLocale(
      value ? const Locale('fr') : const Locale('en'),
    );
  }

  // ==================== Business Logic ====================
  Future<void> _initialize() async {
    try {
      isLoading.value = true;

      // Splash screen delay
      await Future.delayed(const Duration(seconds: 5));

      // Check authentication status and navigate
      await _checkAuthAndNavigate();
    } catch (e) {
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.onboardingScreen);
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final roles = prefs.getStringList('userRole') ?? [];

    if (accessToken != null && accessToken.isNotEmpty) {
      isAuthenticated.value = true;
      userRoles.value = roles;

      // Initialize FCM for already logged in user
      await _fcmService.initFCM(accessToken: accessToken);

      // Navigate based on role
      if (roles.contains('DRIVER')) {
        await _handleDriverNavigation(accessToken);
      } else {
        Get.offAllNamed(AppRoutes.passengerHomeScreen);
      }
    } else {
      isAuthenticated.value = false;
      userRoles.value = [];
      Get.offAllNamed(AppRoutes.onboardingScreen);
    }
  }

  Future<void> _handleDriverNavigation(String accessToken) async {
    try {
      // Call onboarding status API
      final onboardingResponse = await _authService.getDriverOnboardingStatus(
        accessToken: accessToken,
      );

      if (onboardingResponse.isSuccess) {
        // Check if driver is onboarded
        final isOnboarded =
            onboardingResponse.responseData['data']?['isOnboarded'] ?? false;

        if (isOnboarded) {
          // Driver is fully onboarded, go to driver home screen
          Get.offAllNamed(AppRoutes.driverHomeScreen);
        } else {
          // Driver needs to complete onboarding
          Get.offAllNamed(AppRoutes.driverRegistrationScreen);
        }
      } else {
        // If onboarding status check fails, assume not onboarded
        Get.offAllNamed(AppRoutes.driverRegistrationScreen);
      }
    } catch (e) {
      debugPrint('Error checking driver onboarding status: $e');
      // On error, default to registration screen
      Get.offAllNamed(AppRoutes.driverRegistrationScreen);
    }
  }
}
