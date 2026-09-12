import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class DriverRegistrationController extends GetxController {
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
  final RxInt currentStep = 0.obs;
  final RxString errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

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

  void nextStep() {
    if (validateCurrentStep()) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> register() async {
    if (!validateForm()) {
      return;
    }

    if (!isAgreedToTerms.value) {
      errorMessage.value = 'Please agree to terms and conditions';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual registration API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to document upload screen
      // Get.toNamed(AppRoutes.uploadDocumentsScreen);

    } catch (e) {
      debugPrint('driver_registration_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Validation ====================
  bool validateCurrentStep() {
    return formKey.currentState?.validate() ?? false;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.firstNameRequiredError;
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.lastNameRequiredError;
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
