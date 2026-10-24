import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:ride_sharing/routes/app_routes.dart';

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Get.offAllNamed(AppRoutes.passengerAuthSelectionScreen),
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),
      child: Text(AppLocalizations.of(context)!.skipButton),
    );
  }
}
