import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/view/log_out_dialog.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/session_controller.dart';
import 'package:ride_sharing/widgets/custom_button.dart';

/// A signed-in driver awaiting review or whose account needs support.
class AccountStatusScreen extends StatefulWidget {
  const AccountStatusScreen({super.key});

  @override
  State<AccountStatusScreen> createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen> {
  final SessionController session = SessionController.to;
  bool _checking = false;

  Future<void> _checkStatus() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final loaded = await session.loadAccount();
      if (!loaded) {
        AppSnackbar.error(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
        );
        return;
      }
      switch (session.accountState.value) {
        case 'ACTIVE':
          Get.offAllNamed(
            session.roles.contains('DRIVER')
                ? AppRoutes.driverHomeScreen
                : AppRoutes.passengerHomeScreen,
          );
        case 'NEEDS_ONBOARDING':
          Get.offAllNamed(AppRoutes.driverRegistrationScreen);
        case 'PENDING_REVIEW':
          AppSnackbar.show(
            title: AppLocalization.tr.accountStatusPendingTitle,
            message: AppLocalization.tr.accountStatusStillPending,
          );
      }
      // Any other state is already reflected on screen via accountState.
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _logOut() async {
    final result = await LogoutDialog.show(context);
    if (result == true) Get.offAllNamed(AppRoutes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: Obx(() {
          final status = _StatusContent.of(session.accountState.value);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                Expanded(
                  // Centred when it fits, scrollable on small screens.
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatusIcon(icon: status.icon, color: status.color),
                            SizedBox(height: 28.h),
                            Text(
                              status.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.appBarTitleColor,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              status.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: AppColors.appGreyColor,
                              ),
                            ),
                            if (status.showProgress) ...[
                              SizedBox(height: 32.h),
                              const _ReviewProgress(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (status.primaryAction != _PrimaryAction.none)
                  CustomButton(
                    onPressed: _checking
                        ? null
                        : status.primaryAction == _PrimaryAction.continueSetup
                        ? () => Get.offAllNamed(
                            AppRoutes.driverRegistrationScreen,
                          )
                        : _checkStatus,
                    title: _checking
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : null,
                    label: _checking
                        ? null
                        : status.primaryAction == _PrimaryAction.continueSetup
                        ? AppLocalization.tr.continueSetupButton
                        : AppLocalization.tr.checkStatusButton,
                  ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: _logOut,
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: Text(
                    AppLocalization.tr.logoutButton,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}

enum _PrimaryAction { checkStatus, continueSetup, none }

/// What the screen shows for each account state.
class _StatusContent {
  const _StatusContent({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.primaryAction = _PrimaryAction.checkStatus,
    this.showProgress = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final _PrimaryAction primaryAction;
  final bool showProgress;

  static _StatusContent of(String? state) {
    final tr = AppLocalization.tr;
    switch (state) {
      case 'REJECTED':
        return _StatusContent(
          icon: Icons.cancel_outlined,
          color: AppColors.red,
          title: tr.accountStatusRejectedTitle,
          message: tr.accountRejectedMessage,
        );
      case 'SUSPENDED':
        return _StatusContent(
          icon: Icons.block_rounded,
          color: AppColors.red,
          title: tr.accountStatusSuspendedTitle,
          message: tr.accountSuspendedMessage,
        );
      case 'DELETED':
        return _StatusContent(
          icon: Icons.person_off_outlined,
          color: AppColors.appGreyColor,
          title: tr.accountStatusDeletedTitle,
          message: tr.accountDeletedMessage,
          primaryAction: _PrimaryAction.none,
        );
      case 'NEEDS_ONBOARDING':
        return _StatusContent(
          icon: Icons.assignment_outlined,
          color: AppColors.primaryColor,
          title: tr.driverOnboardingTitle,
          message: tr.onboardingRequiredMessage,
          primaryAction: _PrimaryAction.continueSetup,
        );
      default:
        // PENDING_REVIEW, and the fallback for anything unexpected.
        return _StatusContent(
          icon: Icons.hourglass_top_rounded,
          color: AppColors.primaryColor,
          title: tr.accountStatusPendingTitle,
          message: tr.accountStatusPendingBody,
          showProgress: true,
        );
    }
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112.r,
      width: 112.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        height: 80.r,
        width: 80.r,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 40.r, color: color),
      ),
    );
  }
}

/// Where a pending application stands: the first two steps are done by the
/// time this screen can show, review is in progress, driving comes next.
class _ReviewProgress extends StatelessWidget {
  const _ReviewProgress();

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalization.tr;
    final steps = [
      (tr.accountStatusStepCreated, _StepState.done),
      (tr.accountStatusStepSubmitted, _StepState.done),
      (tr.accountStatusStepReview, _StepState.current),
      (tr.accountStatusStepDrive, _StepState.upcoming),
    ];
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              label: steps[i].$1,
              state: steps[i].$2,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.state,
    required this.isLast,
  });

  final String label;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final active = state != _StepState.upcoming;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _StepDot(state: state),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: state == _StepState.done
                        ? AppColors.primaryColor
                        : AppColors.grayShade100.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2.h, bottom: isLast ? 0 : 18.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: state == _StepState.current
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: active
                      ? AppColors.appBarTitleColor
                      : AppColors.appGreyColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final size = 22.r;
    switch (state) {
      case _StepState.done:
        return Container(
          height: size,
          width: size,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 14.r, color: AppColors.white),
        );
      case _StepState.current:
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          alignment: Alignment.center,
          child: Container(
            height: 8.r,
            width: 8.r,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      case _StepState.upcoming:
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayShade100, width: 2),
          ),
        );
    }
  }
}
