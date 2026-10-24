part of 'driver_trip_flow.dart';

class PendingTripsBottomSheet extends StatelessWidget {
  const PendingTripsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] PendingTripsBottomSheet appeared');
    final controller = Get.find<DriverTripController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Expanded(
            child: Obx(() => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.pendingTrips.length,
              itemBuilder: (context, index) {
                final trip = controller.pendingTrips[index];
                return TripRequestCard(
                  trip: trip,
                  onTap: () => controller.selectTrip(trip),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

class TripRequestCard extends StatelessWidget {
  final TripRequest trip;
  final VoidCallback onTap;

  const TripRequestCard({
    Key? key,
    required this.trip,
    required this.onTap,
  }) : super(key: key);

  static final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
    //  height: MediaQuery.of(context).size.height ,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.passengerName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star,
                              size: 12.sp,
                              color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                            )),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            trip.rating.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.pickupTime,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tesxtColor,
                      ),
                    ),
                    Text(
                      trip.vehicleType,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Fare and distance
            Row(
              children: [
                Text(
                  l10n.fareLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.tesxtColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  formatPrice(trip.fare, decimals: 0),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${trip.distance} km',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Locations
            Container(
              decoration: BoxDecoration(
                color: Colors.white,                      // background (change if needed)
                borderRadius: BorderRadius.circular(16.r), // rounded corners
                border: Border.all(
                  color: Colors.grey.shade300,            // grey border
                  width: 1,
                ),
              ),
              child: Padding(
                padding:  EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Image.asset(AppImage.passenger),
                        SizedBox(height: 4.h),
                       CustomVerticalLine(height: 30.h, color: Colors.black),
                        SizedBox(height: 4.h),
                        Icon(Icons.location_on,color: AppColors.togglebuttonColor,)
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pickUp,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Text(
                            trip.pickupLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.dropOff,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Text(
                            trip.dropoffLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Ride Needs
            if (trip.rideNeeds.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: trip.rideNeeds.map((need) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    need.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],

            // Rider phone number — only shown when available
            if (trip.riderNumber.isNotEmpty) ...[
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: trip.riderNumber);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.phone, color: AppColors.primaryColor, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      trip.riderNumber,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Note
            if (trip.note.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.noteLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tesxtColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      trip.note,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      _logger.i('Accept button tapped - rideId: ${trip.id}');
                      final offered = await SocketIoService.to.emitNewOffer(rideId: trip.id);
                      if (offered) {
                        _logger.i('new-offer accepted for rideId: ${trip.id}');
                        onTap();
                      } else {
                        Get.snackbar(l10n.errorTitle, l10n.genericErrorMessage);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.acceptButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Expanded(
                //   child: OutlinedButton(
                //     onPressed: onTap,
                //     style: OutlinedButton.styleFrom(
                //       padding: EdgeInsets.symmetric(vertical: 12.h),
                //       side: BorderSide(color: AppColors.grayShade100),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8.r),
                //       ),
                //     ),
                //     child: Text(
                //       l10n.bidButton,
                //       style: TextStyle(
                //         color: AppColors.appGreyColor,
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.find<DriverTripController>().closeTripFlow(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.cancelButton,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
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

// 2. Trip Detail (Image 2)
class TripDetailBottomSheet extends StatelessWidget {
  const TripDetailBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] TripDetailBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height:MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: SizedBox(
              height: 3.h,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 10.sp,bottom: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconWidget(
                    width: 40.0,
                    height: 40.0,
                    fontSize: 15.sp,
                  ),
                  IconButton(
                          onPressed: () => controller.searchAgain(),
                          icon: Icon(Icons.close),
                        ),
                ],
              ),
            ),
            // Close button
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: EdgeInsets.only(right: 16.w),
            //     child: IconButton(
            //       onPressed: () => controller.searchAgain(),
            //       icon: Icon(Icons.close),
            //     ),
            //   ),
            // ),

            // Passenger info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(

                          trip.passengerName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(
                                Icons.star,
                                size: 14.sp,
                                color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                              )),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${trip.rating})',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatPrice(trip.fare, decimals: 0),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        '${trip.distance} km',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:  10.sp ),
              child: CustomHorizontalLine(
                thickness: 2.sp,
                color: Colors.black38,
              ),
            ),
            SizedBox(height: 24.h),

            // Locations
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(

                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.pickUp,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.tesxtColor,
                              ),
                            ),
                            Text(
                              trip.pickupLocation,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dropOff,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.tesxtColor,
                              ),
                            ),
                            Text(
                              trip.dropoffLocation,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:  10.sp ),
              child: CustomHorizontalLine(
                thickness: 2.sp,
                color: Colors.black38,
              ),
            ),
            SizedBox(height: 16.h),

            // Ride Needs
            if (trip.rideNeeds.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    l10n.rideRequirements,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tesxtColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: trip.rideNeeds.map((need) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        need.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),

            // Passenger note
            if (trip.note.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.passengersNote,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        trip.note,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

           // const Spacer(),
            SizedBox(height: 16.h,),
            // Action buttons
            Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50.h,
                  //   child: OutlinedButton(
                  //     onPressed: () => controller.showBiddingScreen(),
                  //     style: OutlinedButton.styleFrom(
                  //     //  padding: EdgeInsets.symmetric(vertical: 20.h), // increased height
                  //       side: BorderSide(color: AppColors.grayShade100, width: 2),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(24.r),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       l10n.bidButton,
                  //       style: TextStyle(
                  //         color: AppColors.grayShade100,
                  //         fontSize: 18.sp, // increased size
                  //         fontWeight: FontWeight.w700,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

            ),
          ]))
          ) ],
      ),
    );
  }
}

// 3. Bidding Screen (Image 3)
