import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/utils/app_colors.dart';

class CustomBoxItems extends StatelessWidget {
  final String documentTitle;
  final bool isUploaded;
  final VoidCallback onTap;
  final IconData icon;

  const CustomBoxItems({
    super.key,
    required this.documentTitle,
    required this.isUploaded,
    required this.onTap,
    this.icon = Icons.description_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$documentTitle, ${isUploaded ? 'uploaded' : 'not uploaded'}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isUploaded
                  ? AppColors.primaryColor.withValues(alpha: 0.4)
                  : AppColors.grayShade100.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.greenShade50
                      : const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isUploaded ? Icons.check_circle_outline : icon,
                  size: 26.sp,
                  color: isUploaded
                      ? AppColors.primaryColor
                      : AppColors.appGreyColor,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documentTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isUploaded ? 'Uploaded' : 'Not Uploaded',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: isUploaded
                            ? AppColors.successColor
                            : AppColors.appGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward,
                size: 18.sp,
                color: AppColors.darkColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
