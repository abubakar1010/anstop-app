import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/splash_screen/onboarding_page_second.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_sliding_container.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';

import '../../widgets/custom_fade_slide.dart';



class OnboardingPageFirst extends StatelessWidget{
  const OnboardingPageFirst({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// Top bar
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
                    _skipButton(l10n),
                  ],
                ),
              ),

              SizedBox(height: 100.h),

              /// Image
              CustomFadeSlide(
                delay: 150,
                child: Image.asset(
                  AppImage.undrawMyLocation,
                  height: 360.h,
                  width: 285.w,
                ),
              ),

              SizedBox(height: 10.h),

              /// Title
              CustomFadeSlide(
                delay: 300,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.onboardingWelcomeTo, style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    SizedBox(
                      height: 30.h,
                      child: Image.asset(
                        AppImage.textLogo,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              /// Description
              CustomFadeSlide(
                delay: 450,
                child: Text(
                  l10n.onboardingTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),

              SizedBox(height: 20.h),

              /// Indicator
              CustomFadeSlide(
                delay: 600,
                child: OnboardingIndicator(
                  totalPages: 3,
                  currentPage: 0,
                  activeWidth: 21,
                  inactiveWidth: 13,
                  height: 5,
                  borderRadius: 100,
                  activeColor: AppColors.violetFoundation,
                  inactiveColor: AppColors.greyShade,
                  spacing: 5,
                ),
              ),

              SizedBox(height: 20.h),

              /// Button
              CustomFadeSlide(
                delay: 750,
                child:
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingPageSecond()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.r),
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

  Widget _skipButton(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(l10n.skipButton),
    );
  }
}