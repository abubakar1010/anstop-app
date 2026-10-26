import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/auth/data/forgot_password_request_model.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class EmailValidationController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController emailTEController = TextEditingController();

  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isEmailSent = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isPasswordReset = false.obs;
  final formKey = GlobalKey<FormState>();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    // Get arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      // Get email from arguments if available
      final email = args['email'];
      if (email != null) {
        emailTEController.text = email;
      }
      // Check if this is for password reset
      isPasswordReset.value = args['isPasswordReset'] ?? false;
    }
  }

  @override
  void onClose() {
    emailTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  Future<void> sendVerificationEmail() async {
    if (!validateEmail()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isPasswordReset.value) {
        // Call forgot password API
        final request = ForgotPasswordRequestModel(
          email: emailTEController.text.trim(),
        );
        final response = await _authService.forgotPassword(request);

        if (response.isSuccess) {
          isEmailSent.value = true;
          // Navigate to OTP screen with password reset flag
          Get.toNamed(
            AppRoutes.otpVerificationScreen,
            arguments: {
              'email': emailTEController.text.trim(),
              'isPasswordReset': true,
            },
          );
        } else {
          debugPrint('email_validation_controller: ${response.errorMessage}');
          errorMessage.value = AppLocalization.tr.genericErrorMessage;
          AppSnackbar.snackbar(
            AppLocalization.tr.errorTitle,
            AppLocalization.tr.genericErrorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // For email verification, just navigate to OTP screen
        // (OTP is sent during signup)
        Get.toNamed(
          AppRoutes.otpVerificationScreen,
          arguments: {
            'email': emailTEController.text.trim(),
            'isPasswordReset': false,
          },
        );
      }
    } catch (e) {
      debugPrint('email_validation_controller: $e');
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

  // ==================== Validation ====================
  bool validateEmail() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.emailRequiredError;
    }
    if (!GetUtils.isEmail(value)) {
      return AppLocalization.tr.invalidEmailError;
    }
    return null;
  }

  // ==================== Navigation ====================
  void goBack() {
    Get.back();
  }
}
