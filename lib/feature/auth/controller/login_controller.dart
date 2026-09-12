import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/data/signin_request_model.dart';
import 'package:ride_sharing/feature/auth/data/signin_response_model.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/fcm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class LoginController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

  // ==================== Services ====================
  final AuthService _authService = AuthService();
  final FcmService _fcmService = FcmService();


  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    emailTEController.clear();
    passwordTEController.clear();
    super.onClose();
  }

  // ==================== UI Actions ====================
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!validateCredentials()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create signin request model
      final signInRequest = SignInRequestModel(
        email: emailTEController.text.trim(),
        password: passwordTEController.text.trim(),
      );

      // Call signin API
      final response = await _authService.signIn(signInRequest);
      if (response.isSuccess) {
        // Parse the response data
        final signInResponse = SignInResponseModel.fromJson(response.responseData);

        // Check if user needs email verification
        if (signInResponse.data.needsVerification) {
          AppSnackbar.warning(AppLocalization.tr.verificationRequiredTitle, AppLocalization.tr.verifyEmailToContinueMessage);
          Get.toNamed(
            AppRoutes.emailValidationScreen,
            arguments: {'email': emailTEController.text.trim()},
          );
          return;
        }

        // Validate tokens before proceeding
        if (signInResponse.data.accessToken.isEmpty ||
            signInResponse.data.refreshToken.isEmpty) {
          AppSnackbar.error(AppLocalization.tr.loginFailedTitle, AppLocalization.tr.invalidServerResponseMessage);
          return;
        }

        // Save tokens and user data to shared preferences
         await _saveUserData(signInResponse.data);
        if (signInResponse.data.accessToken.isNotEmpty) {
          // Push registration is best-effort and must never block sign-in: the
          // user is already authenticated and their tokens are saved by here.
          try {
            await _fcmService.initFCM(
              accessToken: signInResponse.data.accessToken,
            );
          } catch (e) {
            debugPrint('FCM init failed, continuing sign-in: $e');
          }
        }else{
          debugPrint("No access token for fcm token");
        }
        // Show success message
        // Get.snackbar(
        //   'Success',
        //   signInResponse.message,
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );

        // Handle navigation based on role
        if (signInResponse.data.role.contains('RIDER')) {
          Get.toNamed(AppRoutes.passengerHomeScreen);
        } else if (signInResponse.data.role.contains('DRIVER')) {
          // Check driver onboarding status
          await _handleDriverNavigation(signInResponse.data.accessToken);
        } else {
          Get.toNamed(AppRoutes.passengerHomeScreen);
        }
      } else {
        // Show error message
        debugPrint('login_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.loginFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('login_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> navigateToHomeByRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roles = prefs.getStringList('userRole') ?? [];

    if (roles.contains('DRIVER')) {
      Get.toNamed(AppRoutes.driverHomeScreen);
    } else if (roles.contains('RIDER')) {
      Get.toNamed(AppRoutes.passengerHomeScreen);
    } else {
      Get.toNamed(AppRoutes.passengerHomeScreen);
    }
  }

  // ==================== Helper Methods ====================
  Future<void> _saveUserData(SignInData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data.accessToken);
      await prefs.setString('refreshToken', data.refreshToken);
      await prefs.setStringList('userRole', data.role);
      await prefs.setBool('needsVerification', data.needsVerification);

      // Try to get userId from data first, or decode from JWT token
      String? userId = data.userId;
      if (userId == null || userId.isEmpty) {
        userId = _extractUserIdFromToken(data.accessToken);
      }

      // Save user info for messaging and other features
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString('userId', userId);
      }
      if (data.firstName != null && data.firstName!.isNotEmpty) {
        await prefs.setString('firstName', data.firstName!);
      }
      if (data.lastName != null && data.lastName!.isNotEmpty) {
        await prefs.setString('lastName', data.lastName!);
      }
      if (data.profilePicture != null && data.profilePicture!.isNotEmpty) {
        await prefs.setString('profilePicture', data.profilePicture!);
      }

    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  /// Decode JWT token to extract user ID
  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed for base64 decoding
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = jsonDecode(decoded);

      return data['_id'] as String?;
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
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
        final isOnboarded = onboardingResponse.responseData['data']?['isOnboarded'] ?? false;

        if (isOnboarded) {
          // Driver is fully onboarded, go to driver home screen
          Get.toNamed(AppRoutes.driverHomeScreen);
        } else {
          // Driver needs to complete onboarding
          Get.toNamed(AppRoutes.driverRegistrationScreen);
        }
      } else {
        // If onboarding status check fails, assume not onboarded
        Get.toNamed(AppRoutes.driverRegistrationScreen);
      }
    } catch (e) {
      print('Error checking driver onboarding status: $e');
      // On error, default to registration screen
      Get.toNamed(AppRoutes.driverRegistrationScreen);
    }
  }

  // ==================== Validation ====================
  bool validateCredentials() {
    if (formKey.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.emailRequiredError;
    }
    if (!GetUtils.isEmail(value)) {
      return AppLocalization.tr.invalidEmailError;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.passwordRequiredError;
    }
    if (value.length < 6) {
      return AppLocalization.tr.passwordTooShortError;
    }
    return null;
  }

  // ==================== Navigation ====================
  void navigateToForgotPassword() {
    Get.toNamed(
      AppRoutes.emailValidationScreen,
      arguments: {'isPasswordReset': true},
    );
  }

  void navigateToSignUp(bool isDriver) {
    // if (isDriver) {
    //   Get.toNamed(AppRoutes.driverRegistrationScreen);
    // } else {
    //   Get.toNamed(AppRoutes.passengerRegistrationScreen);
    // }
  }
}
