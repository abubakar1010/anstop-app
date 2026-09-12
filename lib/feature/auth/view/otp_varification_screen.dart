import 'package:ride_sharing/feature/auth/view/reset_password_screen.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/feature/auth/controller/otp_verification_controller.dart';

import '../../../custom_assets/app_image.dart';

class OtpVarificationScreen extends StatelessWidget {
  OtpVarificationScreen({super.key});

  final OtpVerificationController _controller = Get.put(OtpVerificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalization.tr.otpAppBarText),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
        foregroundColor: Color(0XFF0A0A0A),
        forceMaterialTransparency: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 66.h),
              Image.asset(
                  AppImage.logoAnstop
              ),
              SizedBox(height: 52.h),
              CustomPinCodeTextField(
                textEditingController: _controller.otpController,
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalization.tr.otpDidNotGetText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0XFF8A8A8A),
                      ),
                    ),
                    Text(
                      AppLocalization.tr.resendButtonText,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationThickness: 2.r,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 67.h),

              Obx(() => CustomButton(
                onPressed: _controller.isLoading.value ? null : () {
                  _controller.verifyOTP();
                },
                label: _controller.isLoading.value
                    ? 'Verifying...'
                    : AppLocalization.tr.otpVarificationButtonText,
              )),
              Spacer(),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
