import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/utils/app_colors.dart';
import '../../../../custom_assets/app_image.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class UserInfoCard extends StatefulWidget {
  final String profileImageUrl;  // Profile picture URL
  final String name;             // User's name
  final double rating;           // User's rating (1 to 5)
  final double price;            // Price information
  final String distance;         // Distance info
  final String address;          // Address info
  final String location;         // Location info

  const UserInfoCard({
    Key? key,
    required this.profileImageUrl,
    required this.name,
    required this.rating,
    required this.price,
    required this.distance,
    required this.address,
    required this.location,
  }) : super(key: key);

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  int? rating;

  @override
  void initState() {
    super.initState();
    rating = widget.rating.toInt();  // Initialize rating from widget
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  widget.profileImageUrl,
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  // Compact rating stars
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
                          color: index < rating!
                              ? Colors.yellow
                              : Colors.grey,
                          size: 16.sp,
                        ),
                      );
                    }),
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatPrice(widget.price)),
                  Text(widget.distance)
                ],
              ),
            ],
          ),
          Divider(
            color: AppColors.grayShade100,  // Divider color
            thickness: 1,  // Divider thickness
            indent: 0,  // Left indent (optional)
            endIndent: 0,  // Right indent (optional)
          ),
          SizedBox(height: 8.sp),
          Row(
            children: [
              Container(
                child: Image.asset(AppImage.greetings),
              ),
              SizedBox(width: 5.sp),
              Text(widget.address),
            ],
          ),
          SizedBox(height: 8.sp),
          Container(
            height: 20.h,
            width: 2,
            color: Colors.black,
          ),
          Row(
            children: [
              Container(
                child: Icon(Icons.location_on, color: AppColors.primaryColor),
              ),
              SizedBox(width: 5.sp),
              Text(widget.location),
            ],
          ),
          Divider(
            color: AppColors.grayShade100,  // Divider color
            thickness: 1,  // Divider thickness
            indent: 0,  // Left indent (optional)
            endIndent: 0,  // Right indent (optional)
          ),
        ],
      ),
    );
  }
}
