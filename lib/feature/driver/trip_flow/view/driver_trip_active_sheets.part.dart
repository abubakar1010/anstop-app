part of 'driver_trip_flow.dart';

class TripTakenBottomSheet extends StatelessWidget {
  const TripTakenBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] TripTakenBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 24.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Success icon
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
              size: 40.sp,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            AppLocalization.tr.rideAcceptedTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.tesxtColor,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            AppLocalization.tr.navigateToPickupMessage,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 24.h),

          // Go to map button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Close bottom sheet and navigate to map with TripAcceptedBottomSheet
                 // Get.back();
                  controller.goToMapWithPickupRoute();
                },
                icon: Icon(Icons.map, color: Colors.white),
                label: Text(
                  l10n.goToMap,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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

// 5. Trip Accepted - Pickup Location (Image 5)
class TripAcceptedBottomSheet extends StatelessWidget {
  const TripAcceptedBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] TripAcceptedBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value;

    return Container(
      height: 300.h,
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.pickupLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,color: AppColors.togglebuttonColor,) ,
                      Text(
                        "${AppLocalization.tr.iWillPickYouUpLabel} ",
                     //   trip.pickupLocation,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () => controller.confirmPickup(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                       // padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        l10n.confirmPickup,
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
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// 6. Active Trip with Navigation (Image 6)
class ActiveTripBottomSheet extends StatelessWidget {
  const ActiveTripBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] ActiveTripBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Navigation banner

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(0),
          ),
          margin: EdgeInsets.symmetric(vertical: 75.sp),
          child: Row(
            children: [
              Icon(
                Icons.navigation,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                '200 m    Turn right at block b, road no 18',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Bottom sheet
        Container(
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

              // Trip status
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.grayShade100,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    AppLocalization.tr.onATripLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tesxtColor,
                    ),
                  ),
                ),
              ),


              SizedBox(height: 16.h),

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
              padding:  EdgeInsets.symmetric(horizontal:  16.sp),
              child: CustomHorizontalLine(thickness: 2,color: AppColors.grayShade100,),
            ),
              SizedBox(height: 24.h),

              // Trip details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.pickUp,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.dropOff,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            // 'Block B, Banasree, Dhaka.', // static placeholder
                            trip.pickupLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            // 'Dhanmondi, Dhaka', // static placeholder
                            trip.dropoffLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

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
                            fontWeight: FontWeight.w500,
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

              SizedBox(height: 24.h),

              // Accept offer button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.startDropOff(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.acceptOffer,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DropOffNavigationBottomSheet extends StatelessWidget {
  const DropOffNavigationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] DropOffNavigationBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.r)),
      ),
      child: Padding(
        padding:  EdgeInsets.all(16.sp),
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
          SizedBox(height: 10.h,),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Passenger info
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
                             // SizedBox(height: 2.h),
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
                                    // '5.0', // static placeholder
                                    trip.rating.toStringAsFixed(1),
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
                      ],
                    ),

                   // SizedBox(height: 16.h),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 16.h),

                    // Trip info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.pickUp,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Text(
                                trip.pickupLocation,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dropOff,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                trip.dropoffLocation,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Time, Distance, Fare
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'EST',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '6 min', // TODO: wire to real-time navigation ETA
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                l10n.distanceLabel,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                // '3.3 km', // static placeholder
                                '${trip.distance} km',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                l10n.fareLabel,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                // '€ 24', // static placeholder
                                formatPrice(trip.fare, decimals: 0),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Complete Trip Button - emits drop-off-rider and shows payment dialog
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal:  16.sp),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => controller.completeTrip(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenShade300,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                          ),
                          child: Text(
                            l10n.dropOffButton,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    CustomHorizontalLine(thickness: 2,),
                    SizedBox(height: 20.h),
                    // Navigation directions
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        NavigationStep(
                          icon: Icons.straight,
                          instruction: 'Head west on Road No. 3',
                          distance: '240 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_left,
                          instruction: 'Turn left onto Ave 3',
                          distance: '80 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right onto Road No. 5',
                          distance: '400 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_left,
                          instruction: 'Turn left',
                          distance: '110 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right at Titas Gas Rd',
                          distance: '160 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_left,
                          instruction: 'Turn left',
                          distance: '130 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right at Rampura',
                          distance: '160 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right',
                          distance: '400 m',
                        ),
                      ],
                    ),
                  ],
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

// 8. Drop-off Arrived with Navigation Banner (Image 2)
class DropOffArrivedBottomSheet extends StatelessWidget {
  const DropOffArrivedBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] DropOffArrivedBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final homeController = Get.find<DriverHomeScreenController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Stack(
        children: [
          // Navigation banner at top (with some top margin)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.only(top: 70.w), // Adjust as needed
              child: Row(
                children: [
                  Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() {
                      final distance = homeController.currentStepDistance.value;
                      final instruction = homeController.currentStepInstruction.value;
                      final text = distance.isNotEmpty
                          ? '$distance    $instruction'
                          : instruction;
                      return Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet anchored to the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
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
                                child: Text(
                                  trip.passengerName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tesxtColor,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  Icons.star,
                                  size: 12.sp,
                                  color: i < trip.rating.floor()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                )),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                // '5.0', // static placeholder
                                trip.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Divider(color: Colors.grey[300]),
                          SizedBox(height: 16.h),

                          // Trip info
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.pickUp,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      trip.pickupLocation,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.dropOff,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      trip.dropoffLocation,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Time, Distance, Fare
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'EST',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '6 min', // TODO: wire to real-time navigation ETA
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.distanceLabel,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      // '3.3 km', // static placeholder
                                      '${trip.distance} km',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.fareLabel,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      // '€ 24', // static placeholder
                                      formatPrice(trip.fare, decimals: 0),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Navigate to Destination Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => controller.startDropOff(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                l10n.dropOffButton,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation step widget
class NavigationStep extends StatelessWidget {
  final IconData icon;
  final String instruction;
  final String distance;

  const NavigationStep({
    Key? key,
    required this.icon,
    required this.instruction,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: AppColors.tesxtColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.tesxtColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomHorizontalLine(thickness: 2,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}












