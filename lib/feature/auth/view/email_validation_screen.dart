import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/widgets/custom_text_field.dart';
import 'package:ride_sharing/widgets/custom_button.dart';
import '../../../widgets/logo.dart';
import '../controller/email_validation_controller.dart';

class EmailValidationScreen extends GetView<EmailValidationController> {
  const EmailValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isPasswordReset.value
              ? AppLocalization.tr.forgetPasswordTextButton
              : AppLocalization.tr.emailValidationAppBarText,
        )),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
        foregroundColor: const Color(0XFF0A0A0A),
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 66.h),
                const IconWidget(),
                SizedBox(height: 52.h),
                CustomTextField(
                  controller: controller.emailTEController,
                  validator: (value) => controller.validateEmailField(value),
                  hintText: AppLocalization.tr.emailHintText,
                  hintextColor: const Color(0XFF02243E),
                  hintextSize: 14.sp,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0XFF191A44),
                  ),
                ),
                const Spacer(),
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        onPressed: () => controller.sendVerificationEmail(),
                        label: controller.isPasswordReset.value
                            ? AppLocalization.tr.resetPasswordConfirmButton
                            : AppLocalization.tr.emailValidationButtonText,
                      ),
                ),
                const Spacer(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
