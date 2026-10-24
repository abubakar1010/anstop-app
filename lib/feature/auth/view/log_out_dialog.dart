import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/services/session_controller.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              AppLocalization.tr.logOutTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),

            // Message
            Text(
              AppLocalization.tr.logOutMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                    ),
                    child: Text(
                      AppLocalization.tr.cancelButton,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await SessionController.to.signOut();

                      // Delete DriverProfileController so next login starts with fresh state
                      // (it is manually Get.put'd in screens, not route-bound, so GetX won't auto-clean it)
                      Get.delete<DriverProfileController>(force: true);

                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalization.tr.logoutButton,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show the dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const LogoutDialog();
      },
    );
  }
}
