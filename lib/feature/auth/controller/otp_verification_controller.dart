import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:ride_sharing/feature/auth/data/forgot_password_request_model.dart';
import 'package:ride_sharing/feature/auth/data/verify_otp_request_model.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class OtpVerificationController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController otpController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt timer = 60.obs;
  final RxBool canResend = false.obs;
  final RxString userEmail = ''.obs;
  final RxBool isPasswordReset = false.obs;
  Timer? _countdownTimer;

  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      // Get email from arguments
      final email = args['email'];
      if (email != null) {
        userEmail.value = email;
      }
      // Check if this is for password reset
      isPasswordReset.value = args['isPasswordReset'] ?? false;
    }
    startTimer();
  }

  @override
  void onClose() {
    otpController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  // ==================== Business Logic ====================
  void startTimer() {
    timer.value = 60;
    canResend.value = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (this.timer.value > 0) {
        this.timer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      errorMessage.value = AppLocalization.tr.pleaseEnterOtpMessage;
      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.pleaseEnterOtpMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (otpController.text.length < 6) {
      errorMessage.value = AppLocalization.tr.invalidOtpMessage;
      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.invalidOtpMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (userEmail.value.isEmpty) {
      errorMessage.value = AppLocalization.tr.emailNotFoundMessage;
      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.emailNotFoundMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create verify OTP request model with appropriate type
      final verifyOtpRequest = VerifyOtpRequestModel(
        otp: otpController.text.trim(),
        email: userEmail.value,
        type: isPasswordReset.value
            ? OtpType.passwordReset
            : OtpType.emailVerification,
      );

      // Call verify OTP API
      final response = await _authService.verifyOtp(verifyOtpRequest);

      if (response.isSuccess) {
        if (isPasswordReset.value) {
          // Extract reset token from verify-OTP response
          final data = response.responseData;
          final resetToken = data is Map
              ? (data['data']?['accessToken'] ??
                  data['data']?['resetToken'] ??
                  data['accessToken'] ??
                  data['token'] ??
                  '')
              : '';

          Get.offNamed(
            AppRoutes.resetPasswordScreen,
            arguments: {'email': userEmail.value, 'resetToken': resetToken},
          );
        } else {
          // Email verification flow - navigate to login screen
          AppSnackbar.snackbar(
            AppLocalization.tr.successTitle,
            AppLocalization.tr.emailVerifiedMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Navigate to login screen
          Get.offAllNamed(AppRoutes.loginScreen);
        }
      } else {
        // Show error message
        debugPrint('otp_verification_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.snackbar(
          AppLocalization.tr.verificationFailedTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('otp_verification_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP() async {
    if (!canResend.value) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final request = ForgotPasswordRequestModel(email: userEmail.value);
      final response = await _authService.forgotPassword(request);

      if (response.isSuccess) {
        startTimer();
        AppSnackbar.snackbar(
          AppLocalization.tr.otpSentTitle,
          AppLocalization.tr.otpResentMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : AppLocalization.tr.genericErrorMessage;
      }
    } catch (e) {
      debugPrint('otp_verification_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Navigation ====================
  void goBack() {
    // Get.back();
  }
}
