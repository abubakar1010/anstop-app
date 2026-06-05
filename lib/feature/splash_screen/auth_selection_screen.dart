import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/auth/view/log_in_screen.dart';
import 'package:ride_sharing/feature/auth/view/registration.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';

import '../../routes/app_routes.dart';
class AuthSelectionScreen extends StatelessWidget {
  final String? role;

  const AuthSelectionScreen({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
               SizedBox(height: 150.h),
              Center(
                child: Image.asset(
                      AppImage.rafiki,
                  height: 300.h,
                  width: 348.w,
                  fit: BoxFit.contain,
                ),

              ),

              const SizedBox(height: 30),
              Text(
                l10n.passengerWelcomeTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.passengerAuthTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {

                  Get.to(LogInScreen());

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(l10n.logInButton)
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () {
                //  Get.to(() => RegistrationScreen(role: role ?? 'RIDER'));
                  Get.toNamed(AppRoutes.roleSelectionScreen);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: BorderSide(color: AppColors.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(l10n.registerButton) ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
