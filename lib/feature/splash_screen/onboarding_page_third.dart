import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/splash_screen/onboarding_skip_button.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';

import '../../routes/app_routes.dart';
import '../../widgets/custom_fade_slide.dart';
import '../../widgets/custom_sliding_container.dart';
import '../../widgets/logo.dart';

class OnboardingPageThird extends StatelessWidget{
  const OnboardingPageThird({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomFadeSlide(
                delay: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconWidget(
                      height: 40.h,
                      width: 40.h,
                      fontSize: 14.sp,
                    ),
                    const OnboardingSkipButton(),
                  ],
                ),
              ),
              SizedBox(
                height: 150.h,
              ),
              CustomFadeSlide(
                delay: 150,
                child: Center(
                  child: Image.asset(
                    AppImage.pana,
                    height: 250.h,
                    width: 400.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: 30.h),
              CustomFadeSlide(
                delay: 350,
                child: Center(
                  child: Text(
                    l10n.onboardingBooking,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green400,
                    ),
                  ),
                ),
              ),
              CustomFadeSlide(
                delay: 300,
                child: Text(
                  l10n.onboardingEasyAndConvenient,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              CustomFadeSlide(
                delay: 450,
                child: Text(
                  l10n.onboardingBookingMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 20.h,),
              CustomFadeSlide(
                delay: 500,
                child: OnboardingIndicator(
                  totalPages: 3,
                  currentPage: 2,
                  activeWidth: 21,
                  inactiveWidth: 13,
                  height: 5,
                  borderRadius: 100,
                  activeColor: AppColors.violetFoundation,
                  inactiveColor: AppColors.greyShade,
                  spacing: 5,           // Space between indicators
                ),
              ),
              SizedBox(height: 20.h),
              CustomFadeSlide(
                delay: 600,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.passengerAuthSelectionScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(l10n.getStartedButton),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}


