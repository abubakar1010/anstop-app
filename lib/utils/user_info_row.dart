import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

import '../app/utils/app_colors.dart';
import '../custom_assets/app_image.dart';
import '../widgets/custom_vertical_line.dart';
class UserInfoRow extends StatelessWidget {
  final double rating;
  final int trips;
  final String profession;

  const UserInfoRow({
    Key? key,
    required this.rating,
    required this.trips,
    required this.profession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.star, color: Colors.yellow, size: 15.sp),
        SizedBox(width: 2.w),
        Text('$rating', style: TextStyle(fontSize: 10.sp)),
        SizedBox(width: 5.w),
        CustomVerticalLine(height: 10.h, color: Colors.grey), // Your Custom Vertical Line
        SizedBox(width: 5.w),
        Text(AppLocalization.tr.tripsCount(trips), style: TextStyle(fontSize: 10.sp)),
        SizedBox(width: 5.w),
        CustomVerticalLine(height: 10.h, color: Colors.grey), // Your Custom Vertical Line
        SizedBox(width: 5.w),
        Image.asset(AppImage.steeringWheel, width: 15.w, height: 15.h),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            profession,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.sp, color: AppColors.togglebuttonColor),
          ),
        ),
      ],
    );
  }
}
