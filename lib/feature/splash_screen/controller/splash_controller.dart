import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/fcm_service.dart';
import 'package:ride_sharing/services/locale_service.dart';
import 'package:ride_sharing/services/session_controller.dart';

class SplashController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = true.obs;
  final RxBool isAuthenticated = false.obs;
  final RxList<String> userRoles = <String>[].obs;
  final RxBool isFrench = true.obs;

  // ==================== Services ====================
  final FcmService _fcmService = FcmService();

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
    final session = SessionController.to;
    final restored = await session.loadAccount();
    if (!restored) {
      if (await session.accessToken() == null) {
        Get.offAllNamed(AppRoutes.onboardingScreen);
      } else {
        // Keep credentials on a transient network failure. The next launch
        // can retry without forcing the user through sign-in.
        Get.offAllNamed(AppRoutes.loginScreen);
      }
      return;
    }
    isAuthenticated.value = true;
    userRoles.assignAll(session.roles);
    final token = await session.accessToken();
    if (token != null) {
      try {
        await _fcmService.initFCM(accessToken: token);
      } catch (_) {
        /* best effort */
      }
      LocaleService.syncToServer();
    }
    if (session.accountState.value == 'NEEDS_ONBOARDING') {
      Get.offAllNamed(AppRoutes.driverRegistrationScreen);
    } else if (session.accountState.value != 'ACTIVE') {
      Get.offAllNamed(AppRoutes.accountStatusScreen);
    } else if (session.roles.contains('DRIVER')) {
      Get.offAllNamed(AppRoutes.driverHomeScreen);
    } else {
      Get.offAllNamed(AppRoutes.passengerHomeScreen);
    }
  }
}
