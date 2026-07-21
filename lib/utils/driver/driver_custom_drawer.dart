import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/feature/driver/homepage/view/driver_homescreen.dart';
import 'package:ride_sharing/feature/driver/my_trip/view/my_trip.dart';
import 'package:ride_sharing/feature/driver/wallet/view/driver_wallet_page.dart';
import 'package:ride_sharing/feature/notification/view/notification_screen.dart';
import 'package:ride_sharing/feature/passenger/homepage/view/home_page.dart';
import 'package:ride_sharing/feature/passenger/my_ride/view/my_ride.dart';
import 'package:ride_sharing/feature/settings/view/settings_screen.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

import '../../feature/auth/view/log_in_screen.dart';
import '../../feature/auth/view/log_out_dialog.dart';
import '../../routes/app_routes.dart';
import '../custom_user_rating.dart';

class DriverCustomDrawer extends StatelessWidget {
   DriverCustomDrawer({Key? key}) : super(key: key);
  DriverProfileController driverProfileController = Get.put(DriverProfileController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.drawerShade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Drawer Header
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 24.h, right: 16.w),
            child: Container(
              constraints: BoxConstraints(minHeight: 74.h),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              // color: AppColors.white,
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
                      imagePath: AppImage.notification,
                      text: AppLocalization.tr.notificationMenuItem,
                      onTap: () {
                      //  Get.to(NotificationScreen());
                        Get.toNamed(AppRoutes.notificationScreen);
                      },
                    ),

                    _drawerItem(
                      imagePath: AppImage.carDrawer,
                      text: AppLocalization.tr.myTripsMenuItem,
                      onTap: () {
                      //  Get.to(MyTripPage());
                        Get.toNamed(AppRoutes.passengerMyRideScreen);
                        },
                    ),

                    _drawerItem(
                      imagePath: AppImage.walletDrawer,
                      text: AppLocalization.tr.myEarningsMenuItem,
                      onTap: () {
                      //  Get.to(DriverWalletPage());
                        Get.toNamed(AppRoutes.driverWalletScreen);
                      },
                    ),
                    _drawerItem(
                      imagePath: AppImage.invite,
                      text: AppLocalization.tr.inviteAndEarnsMenuItem,
                      onTap: () {},
                    ),
                    _drawerItem(
                      imagePath: AppImage.support,
                      text: AppLocalization.tr.supportMenuItem,
                      onTap: () {
                        Get.toNamed(AppRoutes.supportListScreen);
                      },
                    ),
                    _drawerItem(
                      imagePath: AppImage.settings,
                      text: AppLocalization.tr.settingsMenuItem,
                      onTap: () {
                        Get.to(SettingsScreen());

                      },
                    ),
                    _drawerItem(
                      imagePath: AppImage.logout,
                      text: AppLocalization.tr.logoutMenuItem,
                      onTap: () async {
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

          // Logout button
          Padding(
            padding: EdgeInsets.all(8.sp),
            child: CustomButton(
              onPressed: (){
                 //  Get.to(HomePage());
                Get.toNamed(AppRoutes.passengerHomeScreen);
              },
              title: Text(AppLocalization.tr.switchToPassengerButton,style: TextStyle(color: AppColors.white),),
            ),
          )
        ],
      ),
    );
  }

  Widget _drawerItem({
    required String imagePath,   // 🔥 changed
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(
        imagePath,
        width: 24.w,       // adjust size as needed
        height: 24.h,
        fit: BoxFit.contain,
      ),
      title: Text(
        text,
        style: TextStyle(fontSize: 15.sp),
      ),
      onTap: onTap,
    );
  }

}
