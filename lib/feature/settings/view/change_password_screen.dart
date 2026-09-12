import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import '../../../app/utils/app_colors.dart';
import '../../../widgets/custom_text_field.dart';
import '../controller/change_password_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: SettingsColors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.tr.changePasswordOption,
          style: const TextStyle(
            color: SettingsColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalization.tr.currentPasswordLabel),
                    CustomTextField(
                      isObscureText: true,
                      isPassword: true,
                      controller: controller.currentPasswordTEController,
                      validator: (value) => controller.validateCurrentPassword(value),
                      prefixIcon: Icon(
                        Icons.key,
                        color: Color(0XFF8A8A8A),
                        size: 24.sp,
                      ),
                      hintText: AppLocalization.tr.enterOldPasswordHint,
                      hintextSize: 14.sp,
                      hintextColor: Color(0XFF8A8A8A),
                    ),
                    SizedBox(height: 12.h),
                    Text(AppLocalization.tr.newPasswordLabel),
                    CustomTextField(
                      isObscureText: true,
                      isPassword: true,
                      controller: controller.newPasswordTEController,
                      validator: (value) => controller.validateNewPassword(value),
                      prefixIcon: Icon(
                        Icons.key,
                        color: Color(0XFF8A8A8A),
                        size: 24.sp,
                      ),
                      hintText: AppLocalization.tr.enterNewPasswordHint,
                      hintextSize: 14.sp,
                      hintextColor: Color(0XFF8A8A8A),
                    ),
                    SizedBox(height: 12.h),
                    Text(AppLocalization.tr.passwordLabel),
                    CustomTextField(
                      isObscureText: true,
                      isPassword: true,
                      controller: controller.confirmPasswordTEController,
                      validator: (value) => controller.validateConfirmPassword(value),
                      prefixIcon: Icon(
                        Icons.key,
                        color: Color(0XFF8A8A8A),
                        size: 24.sp,
                      ),
                      hintText: AppLocalization.tr.reenterPasswordHint,
                      hintextSize: 14.sp,
                      hintextColor: Color(0XFF8A8A8A),
                    ),

                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: SettingsColors.primaryText,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalization.tr.forgetPasswordTextButton,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final success = await controller.changePassword();
                          if (success && context.mounted) {
                            _showSuccessDialog(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsColors.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: SettingsColors.primaryGreen.withOpacity(0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalization.tr.resetPasswordConfirmButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: SettingsColors.primaryGreen,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalization.tr.resetPasswordAppBarText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: SettingsColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                controller.successMessage.value.isNotEmpty
                    ? controller.successMessage.value
                    : AppLocalization.tr.reportSubmittedMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: SettingsColors.secondaryText,
                ),
              )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to settings screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    AppLocalization.tr.okButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
