import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';


// Mock colors - replace with your actual AppColors


// 2. Trip Completion Dialog (Middle Image)
class TripCompletionDialog extends StatelessWidget {
  final VoidCallback onBackToHome;

  const TripCompletionDialog({
    Key? key,
    required this.onBackToHome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 24.sp,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Celebration icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main celebration icon
                  Icon(
                    Icons.celebration,
                    color: Colors.orange,
                    size: 40.sp,
                  ),
                  // Decorative elements (you can customize these)
                  Positioned(
                    top: 10.h,
                    left: 15.w,
                    child: Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20.h,
                    right: 10.w,
                    child: Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15.h,
                    left: 10.w,
                    child: Container(
                      width: 5.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Congratulations text
            Text(
              AppLocalization.tr.tripCompletedCongratsMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.tesxtColor,
              ),
            ),

            SizedBox(height: 32.h),

            // Back to Home button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBackToHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  AppLocalization.tr.backToHomeButton,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Stay Online Dialog (Right Image)
class StayOnlineDialog extends StatelessWidget {
  final VoidCallback onGoOffline;
  final VoidCallback onStayOnline;

  const StayOnlineDialog({
    Key? key,
    required this.onGoOffline,
    required this.onStayOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 24.sp,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Title
            Text(
              AppLocalization.tr.keepOnlineLine1,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tesxtColor,
              ),
            ),

            Text(
              AppLocalization.tr.keepOnlineLine2,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.tesxtColor,
              ),
            ),

            SizedBox(height: 16.h),

            // Subtitle
            Text(
              AppLocalization.tr.stayConnectedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            SizedBox(height: 32.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onGoOffline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      AppLocalization.tr.driverGoOfflineButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onStayOnline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      AppLocalization.tr.stayOnlineButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
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
}

// Helper class to show the dialogs
class TripDialogs {
  // Show trip completion dialog
  static void showTripCompletion(
      BuildContext context, {
        required VoidCallback onBackToHome,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TripCompletionDialog(
        onBackToHome: onBackToHome,
      ),
    );
  }

  // Show stay online dialog
  static void showStayOnline(
      BuildContext context, {
        required VoidCallback onGoOffline,
        required VoidCallback onStayOnline,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StayOnlineDialog(
        onGoOffline: onGoOffline,
        onStayOnline: onStayOnline,
      ),
    );
  }
}
