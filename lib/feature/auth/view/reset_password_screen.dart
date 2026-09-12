import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/auth/controller/reset_password_controller.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.tr.resetPasswordAppBarText),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
        foregroundColor: const Color(0XFF0A0A0A),
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 66.h),
                  Image.asset(AppImage.logoAnstop),
                  SizedBox(height: 52.h),
                  CustomTextField(
                    controller: controller.newPasswordTEController,
                    hintText: AppLocalization.tr.resetPasswordHintText,
                    hintextColor: const Color(0XFF02243E),
                    hintextSize: 14.sp,
                    prefixIcon: const Icon(Icons.key, color: Color(0XFF191A44)),
                    isPassword: true,
                    isObscureText: true,
                    validator: (v) => controller.validateNewPassword(v),
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: controller.confirmPasswordTEController,
                    hintText: AppLocalization.tr.resetConfirmPasswordHintText,
                    hintextColor: const Color(0XFF02243E),
                    hintextSize: 14.sp,
                    prefixIcon: const Icon(Icons.key, color: Color(0XFF191A44)),
                    isPassword: true,
                    isObscureText: true,
                    validator: (v) => controller.validateConfirmPassword(v),
                  ),
                  SizedBox(height: 32.h),
                  Obx(() => CustomButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.resetPassword(),
                    label: controller.isLoading.value
                        ? 'Resetting...'
                        : AppLocalization.tr.resetPasswordConfirmButton,
                  )),
                  Obx(() => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: Colors.red, fontSize: 12.sp),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
