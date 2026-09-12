import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/utils/user_info_row.dart';

import '../app/utils/app_colors.dart';


class UserInfoSection extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double rating;
  final int trips;
  final String profession;
  final String price;
  final String distance;

  const UserInfoSection({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.rating,
    required this.trips,
    required this.profession,
    required this.price,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.togglebuttonColor,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl, // User Image
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
                // Profile URLs from the API are not always real image files,
                // so fall back to a placeholder instead of throwing.
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 30.sp,
                  color: AppColors.togglebuttonColor,
                ),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              ),
            ),
          ),
          SizedBox(width: 12.sp),

          // Inner Column for User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name, // User Name
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              UserInfoRow(
                rating: rating,
                trips: trips,
                profession: profession,
              ),
            ],
          ),
          Spacer(),


          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price),
              Text(distance),
            ],
          ),
        ],
      ),
    );
  }
}


