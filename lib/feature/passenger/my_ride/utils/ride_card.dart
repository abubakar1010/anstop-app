import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MyRideCardWidget extends StatelessWidget {
  final String date;
  final String time;
  final String pickup;
  final String dropoff;
  final String imageUrl;
  final VoidCallback onViewDetails;

  const MyRideCardWidget({
    Key? key,
    required this.date,
    required this.time,
    required this.pickup,
    required this.dropoff,
    required this.imageUrl,
    required this.onViewDetails,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Date & Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    SizedBox(width: 5.sp),
                    Text(
                      time,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                /// Pickup
                Row(
                  children: [
                    Image.asset(AppImage.greetings, width: 20.w, height: 20.h),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pickup,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),


                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.togglebuttonColor, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        dropoff,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.h,
                ),
                CustomButton(onPressed:onViewDetails,
                title: Text(AppLocalization.tr.viewDetailsButton,style: TextStyle(color: Colors.black),),
                  height: 40,
                  backgroundColor: AppColors.white,
                  bordersColor: Colors.grey,
                ),
                
              ],
            ),
          ),

          Positioned(
            right: 16.w,
            top: 5.h,
            bottom: 20.h,
            child: Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.togglebuttonColor,
                  width: 3,
                ),
              ),
              child: Center(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 45.w,
                    height: 45.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        width: 45.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    errorWidget: (context, url, error) => Icon(
                      Icons.person,
                      size: 30.sp,
                      color: AppColors.togglebuttonColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
