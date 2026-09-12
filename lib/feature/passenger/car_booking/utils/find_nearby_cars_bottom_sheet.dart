import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/booking_car_bottomsheet.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/driver_arrived_bottom_sheet.dart';

import '../../../../app/utils/app_colors.dart';

class FindNearbyCarsBottomSheet extends StatefulWidget {
  @override
  _FindNearbyCarsBottomSheetState createState() => _FindNearbyCarsBottomSheetState();
}

class _FindNearbyCarsBottomSheetState extends State<FindNearbyCarsBottomSheet> {
  int rating = 0;
  void initState() {
    super.initState();
    // Automatically navigate to DriverArrivedBottomSheet after 3 seconds
    _autoNavigateToDriverArrived();
  }

  void _autoNavigateToDriverArrived() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close current bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false, // Prevent dismissing by tapping outside
          enableDrag: false, // Prevent dismissing by dragging
          builder: (BuildContext context) {
            return DriverArrivedBottomSheet();
          },
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      color: AppColors.white,
    //  padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalization.tr.findingNearbyCarsLabel,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalization.tr.rideRequestSentMessage,
              style: TextStyle(fontSize: 8.sp),
            ),
          ),
          SizedBox(height: 16.sp),

          // User Info Section with Avatar and Rating
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://picsum.photos/250?image=9', // Placeholder Image URL
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
                      'John Doe',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    // Rating Stars
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
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("\$24"), // Price
                    Text('28 km') // Distance
                  ],
                )
              ],
            ),
          ),

          Container(
            width: double.infinity,
            child: Divider(
              color: Colors.grey[200],
              thickness: 15, // Increased thickness
              indent: 0,
              endIndent: 0,
            ),
          ),

          SizedBox(height: 8.sp),

          // Start and End Location Information
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  child: Image.asset(AppImage.greetings),
                ),
                SizedBox(width: 5.sp),
                Text(AppLocalization.tr.pickupLocationExample2), // Starting location
              ],
            ),
          ),
         // SizedBox(height: 8.sp),
         // SizedBox(width: 12.sp),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 20.h,
              width: 2,
              color: Colors.black,
            ),
          ),

          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryColor),
              SizedBox(width: 5.sp),
              Text(AppLocalization.tr.dropoffLocationExample2), // Destination location
            ],
          ),

          SizedBox(height: 8.sp),

          // Distance Information
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(AppLocalization.tr.distanceLabel),
                Spacer(),
                Text(AppLocalization.tr.distanceValueExample) // Distance Value
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Divider(
              color: Colors.grey[200],
              thickness: 15, // Increased thickness
              indent: 0,
              endIndent: 0,
            ),
          ),
          SizedBox(height: 8.sp),
          
          Padding(
            padding:  EdgeInsets.symmetric(horizontal:  8.sp),
            child: Row(
              children: [
                Image.asset(AppImage.wallet),
                SizedBox(width: 2.sp,),
                Text(AppLocalization.tr.payViaWalletLabel,style: TextStyle(fontSize: 20.sp),)
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: Divider(
              color: Colors.grey[200],
              thickness: 15, // Increased thickness
              indent: 0,
              endIndent: 0,
            ),
          ),
          // Cancel Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalization.tr.cancelRideQuestion),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return BookingCarsBottomSheet(rideId: '');
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red, // Background color of the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // Border radius
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Make the row size fit the content
                    children: [

                      // Space between the icon and the text
                      Text(
                        AppLocalization.tr.cancelNowButton,
                        style: TextStyle(
                          color: Colors.white, // Text color
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.close,
                        color: Colors.white, // Icon color
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
