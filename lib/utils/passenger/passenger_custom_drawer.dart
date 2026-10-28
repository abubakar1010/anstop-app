import 'package:ride_sharing/utils/drawer_navigation.dart';
import 'package:ride_sharing/widgets/unread_badge.dart';
import 'package:ride_sharing/services/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../feature/auth/view/log_out_dialog.dart';
import '../custom_user_rating.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class PassengerCustomDrawer extends StatelessWidget {
  PassengerCustomDrawer({Key? key}) : super(key: key);
  final DriverProfileController driverProfileController = Get.put(DriverProfileController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.drawerShade,
      child: SafeArea(
      // Keeps the menu clear of the status bar and home indicator.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Drawer Header
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 24.h, right: 16.w),
            child: Container(
              constraints: BoxConstraints(minHeight: 74.h),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Obx(() {
                final profile = driverProfileController.profileData.value;
                final name = profile?.firstName ?? '';
                final imageUrl = profile?.profilePicture ?? 'https://picsum.photos/250?image=9';
                return CustomUserRating(
                  name: name,
                  imageUrl: imageUrl,
                );
              }),
            ),
          ),

          // Menu items
          // The menu card hugs its items and the whole block scrolls when the
          // drawer is shorter than the content, so labels never get squeezed.
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),

                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _drawerItem(
                      icon: Icons.home_outlined,
                      text: AppLocalization.tr.homeMenuItem,
                      route: AppRoutes.passengerHomeScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.passengerHomeScreen),
                      ),
                    ),
                    _drawerItem(
                      imagePath: AppImage.notification,
                      text: AppLocalization.tr.notificationMenuItem,
                      trailing: const UnreadBadge(),
                      route: AppRoutes.notificationScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.notificationScreen),
                      ),
                    ),

                    _drawerItem(
                      imagePath: AppImage.carDrawer,
                      text: AppLocalization.tr.myRideMenuItem,
                      route: AppRoutes.passengerMyRideScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.passengerMyRideScreen),
                      ),
                    ),

                    _drawerItem(
                      imagePath: AppImage.walletDrawer,
                      text: AppLocalization.tr.walletMenuItem,
                      route: AppRoutes.passengerWalletScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.passengerWalletScreen),
                      ),
                    ),
                    _drawerItem(
                      icon: Icons.credit_card_outlined,
                      text: AppLocalization.tr.paymentMethodsTitle,
                      route: AppRoutes.paymentMethodsScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.paymentMethodsScreen),
                      ),
                    ),
                    _drawerItem(
                      imagePath: AppImage.support,
                      text: AppLocalization.tr.supportMenuItem,
                      route: AppRoutes.supportListScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.supportListScreen),
                      ),
                    ),
                    _drawerItem(
                      imagePath: AppImage.settings,
                      text: AppLocalization.tr.settingsMenuItem,
                      route: AppRoutes.settingsScreen,
                      onTap: () => _closeDrawerThen(
                        context,
                        () => DrawerNavigation.go(AppRoutes.settingsScreen),
                      ),
                     ),
                    _drawerItem(
                      imagePath: AppImage.logout,
                      text: AppLocalization.tr.logoutMenuItem,
                      onTap: () async {
                        Scaffold.maybeOf(context)?.closeDrawer();
                        // Show the logout dialog
                        final result = await LogoutDialog.show(context);

                        // If user confirmed logout
                        if (result == true) {
                          Get.offAllNamed(AppRoutes.loginScreen);

                        }
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),

          // Switch to Driver button
          Padding(
            padding: EdgeInsets.all(8.sp),
            child: CustomButton(
                onPressed: () => _closeDrawerThen(
                  context,
                  () => _handleSwitchToDriver(context),
                ),
             title: Text(AppLocalization.tr.switchToDriverButton,style: TextStyle(color: AppColors.white),),
            ),
          )
        ],
      ),
      ),
    );
  }

  /// Closes the drawer before running [action].
  ///
  /// Navigating straight from a drawer item leaves the drawer open underneath
  /// the pushed route. On coming back the Scaffold still considers it open, so
  /// the menu button's openDrawer() is a no-op and the drawer "randomly"
  /// stops working.
  void _closeDrawerThen(BuildContext context, VoidCallback action) {
    Scaffold.maybeOf(context)?.closeDrawer();
    action();
  }

  /// Pops the loading dialog without going through `Get.back()`.
  ///
  /// On GetX 4.7.x `Get.back()` closes an open snackbar instead of popping, so
  /// the spinner stayed up underneath the registration screen and blocked the
  /// home screen once the user came back.
  void _closeLoadingDialog() {
    if (Get.isDialogOpen ?? false) Get.key.currentState?.pop();
  }

  Future<void> _handleSwitchToDriver(BuildContext context) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get access token
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();


      if (accessToken == null || accessToken.isEmpty) {
        _closeLoadingDialog();

        // Show dialog asking user to re-login
        await Get.dialog(
          AlertDialog(
            title: Text(AppLocalization.tr.loginRequiredTitle),
            content: Text(AppLocalization.tr.switchToDriverModeMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.toNamed(AppRoutes.loginScreen); // Navigate to login
                },
                child: Text(AppLocalization.tr.goToLoginButton),
              ),
              TextButton(
                onPressed: () => Get.back(), // Close dialog
                child: Text(AppLocalization.tr.cancelButton),
              ),
            ],
          ),
        );
        return;
      }

      // Check onboarding status
      final authService = AuthService();
      final onboardingResponse = await authService.getDriverOnboardingStatus(
        accessToken: accessToken,
      );

      _closeLoadingDialog();

      if (onboardingResponse.isSuccess) {
        final isOnboarded = onboardingResponse.responseData['data']?['isOnboarded'] ?? false;

        if (isOnboarded) {
          // Driver is fully onboarded, go to driver home screen
          // Replaces the rider's pages: back must not return to rider mode.
          Get.offAllNamed(AppRoutes.driverHomeScreen);
        } else {
          // Driver needs to complete onboarding
          Get.toNamed(AppRoutes.driverRegistrationScreen);
        }
      } else {
        // If onboarding status check fails, go to registration
        Get.toNamed(AppRoutes.driverRegistrationScreen);
      }
    } catch (e) {
      _closeLoadingDialog();
      debugPrint('Error switching to driver: $e');
      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _drawerItem({
    String? imagePath,
    IconData? icon,      // for items without an image asset
    required String text,
    required VoidCallback onTap,
    Widget? trailing,
    /// The page this item opens; it is highlighted while that page is shown.
    String? route,
  }) {
    final selected = route != null && Get.currentRoute == route;
    return ListTile(
      // Shows which page is open, like a standard navigation drawer.
      selected: selected,
      selectedTileColor: AppColors.primaryColor.withOpacity(0.08),
      selectedColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      trailing: trailing,
      leading: imagePath != null
          ? Image.asset(
              imagePath,
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
            )
          : Icon(icon, size: 24.w, color: selected ? AppColors.primaryColor : Colors.black87),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }

}
