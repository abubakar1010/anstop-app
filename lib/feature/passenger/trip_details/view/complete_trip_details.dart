import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/passenger/trip_details/controller/completed_trip_controller.dart';
import 'package:ride_sharing/utils/user_info_section.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_vertical_line.dart';
import 'package:intl/intl.dart';

import '../../../../utils/custom_download_tile.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class CompletedTripDetails extends StatefulWidget {
  final String rideId;

  const CompletedTripDetails({super.key, required this.rideId});

  @override
  State<CompletedTripDetails> createState() => _CompletedTripDetailsState();
}

class _CompletedTripDetailsState extends State<CompletedTripDetails> {
  late final CompletedTripController controller;

  @override
  void initState() {
    super.initState();
    // Registered here rather than in build() so the controller's onInit()
    // (which writes isLoading/trip and can fire a snackbar) runs outside the
    // build phase — doing it in build() marked the Obx below dirty mid-build.
    // Tagging by rideId keeps a second trip from reusing the first one's data.
    controller = Get.put(
      CompletedTripController(rideId: widget.rideId),
      tag: widget.rideId,
    );
  }

  @override
  void dispose() {
    Get.delete<CompletedTripController>(tag: widget.rideId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(AppLocalization.tr.tripDetailsTitle),
        centerTitle: true,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.trip.value == null) {
          return Center(
            child: Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : AppLocalization.tr.noTripDetailsMessage,
            ),
          );
        }

        final trip = controller.trip.value!;
        final formattedDate = DateFormat.yMMMd().format(trip.createdAt);
        final formattedTime = DateFormat.jm().format(trip.createdAt);

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Map image container
                Card(
                  elevation: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://media.wired.com/photos/59269cd37034dc5f91bec0f1/191:100/w_1280,c_limit/GoogleMapTA.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text(AppLocalization.tr.mapImageNotAvailable));
                      },
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                Card(
                  elevation: 2,
                  color: AppColors.white,
                  child: Container(
                    height: 85.h,
                    child: Padding(
                      padding: EdgeInsets.all(16.sp),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(trip.driverId.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),),
                              Spacer(),
                              Text(formattedDate, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            children: [
                              Text(AppLocalization.tr.completedStatus, style: TextStyle(color: Colors.green),),
                              Spacer(),
                              Text(formattedTime),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                /// Add other trip detail widgets here...
                Card(
                  color: AppColors.white,
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalization.tr.yourTripLabel, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),),
                        SizedBox(height: 8.sp,),
                        Row(children: [
                          Container(
                            child: Image.asset(AppImage.greetings),
                          ),
                          SizedBox(width: 5.sp,),
                          Expanded(child: Text(trip.pickup.name)),
                        ],),
                        CustomVerticalLine(height: 20.h, color: Colors.black),
                        Row(children: [
                          Container(
                            child: Icon(Icons.location_on, color: AppColors.primaryColor,),
                          ),
                          SizedBox(width: 5.sp,),
                          Expanded(child: Text(trip.destination.name)),
                        ],),
                        SizedBox(height: 8.sp,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalization.tr.distanceLabel, style: TextStyle(
                                fontSize: 18.sp, color: Colors.black
                            ),
                            ),
                            SizedBox(width: 5.sp,),
                            Text(trip.distance),
                          ],),
                        SizedBox(height: 8.h,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Card(
                  elevation: 2,
                  color: AppColors.white,
                  child: Container(
                    height: 36.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp),
                      child: Row(
                        children: [
                          Text(AppLocalization.tr.rideValueLabel),
                          Spacer(),
                          Text(formatPrice(trip.fare)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Card(
                  color: AppColors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        UserInfoSection(
                          imageUrl: trip.driverId.profilePicture ?? AppImage.defaultProfileImageUrl,
                          name: trip.driverId.name,
                          rating: 4.5,
                          trips: 0,
                          profession: AppLocalization.tr.driverLabel,
                          price: formatPrice(trip.fare),
                          distance: trip.distance,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // DownloadRideScriptTile(
                //   onTap: () {
                //     controller.downloadReceipt();
                //   },
                //   iconColor: AppColors.green300,
                //   iconSize: 20,
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
