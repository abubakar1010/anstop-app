import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/feature/driver/profile/view/driver_profile_view.dart';
import 'package:shimmer/shimmer.dart';

import '../app/utils/app_colors.dart';
class CustomUserRating extends StatefulWidget {
  final String name;
  final String imageUrl;
 // final double price;
 // final double distance;

  const CustomUserRating({
    Key? key,
    required this.name,
    required this.imageUrl,
   // required this.price,
  //  required this.distance,
  }) : super(key: key);

  @override
  State<CustomUserRating> createState() => _CustomUserRatingState();
}

class _CustomUserRatingState extends State<CustomUserRating> {
  int rating = 4; // Default rating

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal:  8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: widget.imageUrl != null &&
                widget.imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 100.w,
                  height: 100.h,
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
            )
                : Container(
              color: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 50.sp,
                color: Colors.grey[600],
              ),
            ),
          ),



          SizedBox(width: 12.sp),

          // Name + Rating Stars — Expanded so long names/labels wrap or
          // ellipsize instead of overflowing off the right edge.
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.sp,),
              GestureDetector(
                onTap: (){
                  Get.to(DriverProfileView());
                },
                  child: Text(AppLocalization.tr.goToProfileLink,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.green,fontSize: 10.sp),

                  )

              ),
              SizedBox(height: 2.sp,),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      color: index < rating ? Colors.yellow : Colors.grey,
                      size: 16.sp,
                    ),
                  );
                }),
              ),
            ],
          ),
          ),


        ],
      ),
    );
  }
}
