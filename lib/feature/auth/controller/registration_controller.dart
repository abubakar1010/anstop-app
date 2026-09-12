import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/auth/data/signup_request_model.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/feature/auth/view/email_validation_screen.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class RegistrationController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController firstNameTEController = TextEditingController();
  final TextEditingController lastNameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController phoneTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isAgreedToTerms = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString userRole = 'RIDER'.obs; // Default role
  final formKey = GlobalKey<FormState>();

  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    firstNameTEController.dispose();
    lastNameTEController.dispose();
    emailTEController.dispose();
    phoneTEController.dispose();
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    super.onClose();
  }

  // ==================== UI Actions ====================
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleTermsAgreement(bool? value) {
    isAgreedToTerms.value = value ?? false;
  }

  // ==================== Set Role ====================
  void setRole(String role) {
    userRole.value = role;
  }

  Future<void> register() async {
    if (!validateForm()) {
      return;
    }

    if (!isAgreedToTerms.value) {
      errorMessage.value = 'Please agree to terms and conditions';
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.pleaseAgreeToTermsMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create signup request model
      final signUpRequest = SignUpRequestModel(
        firstName: firstNameTEController.text.trim(),
        lastName: lastNameTEController.text.trim(),
        email: emailTEController.text.trim(),
        password: passwordTEController.text.trim(),
        role: userRole.value,
        // phoneNumber: phoneTEController.text.trim().isNotEmpty
        //     ? phoneTEController.text.trim()
        //     : null,
      );

      // Call signup API
      final response = await _authService.signUp(signUpRequest);

      if (response.isSuccess) {
        // Show success message
        // Get.snackbar(
        //   'Success',
        //   'Registration successful! Please verify your email.',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );

        // Navigate to email validation screen
        Get.toNamed(
          AppRoutes.emailValidationScreen,
          arguments: {'email': emailTEController.text.trim()},
        );
      } else {
        // Show error message
        debugPrint('registration_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        Get.snackbar(
          AppLocalization.tr.registrationFailedTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('registration_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      Get.snackbar(
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
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.nameRequiredError;
    }
    return null;
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

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.phoneRequiredError;
    }
    if (value.length < 10) {
      return AppLocalization.tr.invalidPhoneError;
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.confirmPasswordRequiredError;
    }
    if (value != passwordTEController.text) {
      return AppLocalization.tr.passwordsDoNotMatchError;
    }
    return null;
  }

  // ==================== Navigation ====================
  void navigateToLogin() {
    // Get.back();
  }

  void showTermsAndConditions() {
    // TODO: Show terms and conditions
  }
}
