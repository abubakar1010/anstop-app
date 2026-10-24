import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/session_controller.dart';

/// A signed-in driver awaiting review or whose account needs support.
class AccountStatusScreen extends StatelessWidget {
  const AccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionController.to;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalization.tr.accountInactiveTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Text(
                  _message(session.accountState.value),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (await session.loadAccount() &&
                      session.accountState.value == 'ACTIVE') {
                    Get.offAllNamed(
                      session.roles.contains('DRIVER')
                          ? AppRoutes.driverHomeScreen
                          : AppRoutes.passengerHomeScreen,
                    );
                  }
                },
                child: Text(AppLocalization.tr.accountInactiveButton),
              ),
              TextButton(
                onPressed: () async {
                  await session.signOut();
                  Get.offAllNamed(AppRoutes.loginScreen);
                },
                child: Text(AppLocalization.tr.logoutButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _message(String? state) {
    // Existing localized copy covers the common pending-review case.
    switch (state) {
      case 'PENDING_REVIEW':
        return AppLocalization.tr.accountPendingReviewMessage;
      case 'REJECTED':
        return AppLocalization.tr.accountRejectedMessage;
      case 'SUSPENDED':
        return AppLocalization.tr.accountSuspendedMessage;
      case 'DELETED':
        return AppLocalization.tr.accountDeletedMessage;
      case 'NEEDS_ONBOARDING':
        return AppLocalization.tr.onboardingRequiredMessage;
      default:
        return AppLocalization.tr.accountInactiveMessage;
    }
  }
}
