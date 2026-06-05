import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/auth/view/registration.dart';
import 'package:ride_sharing/feature/splash_screen/driver_auth_selection_screen.dart';
import 'package:ride_sharing/feature/splash_screen/auth_selection_screen.dart';
import 'package:ride_sharing/feature/splash_screen/controller/role_selection_controller.dart';
import 'package:ride_sharing/widgets/custom_fade_slide.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import '../../app/utils/app_colors.dart';
import 'package:get/get.dart';

class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});

  final RoleSelectionController _controller = Get.put(RoleSelectionController());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CustomFadeSlide(
                      delay: 150,
                      child: Image.asset(
                        AppImage.cuate,
                        height: 195.h,
                        width: 300.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    CustomFadeSlide(
                      delay: 300,
                      child: Text(
                        l10n.roleWelcomeTitle,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomFadeSlide(
                      delay: 450,
                      child: Text(
                        l10n.roleTagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomFadeSlide(
                delay: 600,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _controller.selectRole('RIDER');
                            Get.to(() => RegistrationScreen(role: 'RIDER'));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImage.passengerIcon,
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                l10n.asPassengerButton,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        OutlinedButton(
                          onPressed: () {
                            _controller.selectRole('DRIVER');
                            Get.to(() => RegistrationScreen(role: 'DRIVER'));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.green300,
                            side: BorderSide(color: AppColors.green300, width: 2),
                            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            minimumSize: Size(double.infinity, 50.h),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImage.driverIcon,
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                l10n.driverButton,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
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
