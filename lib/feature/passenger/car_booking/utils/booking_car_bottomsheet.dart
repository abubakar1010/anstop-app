import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/cancel_taxi.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/controller/pick_up_location_controller.dart';
import 'package:ride_sharing/feature/passenger/payment/view/passenger_payment_screen.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/utils/cancel_driver_widget.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/car_details.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/driver_arrived_bottom_sheet.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/driver_status_widget.dart';
import 'package:ride_sharing/utils/support_note_widget.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/trip_id.dart';
import 'package:ride_sharing/utils/user_info_section.dart';
import 'package:ride_sharing/widgets/custom_horizontal_line.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class BookingCarsBottomSheet extends StatefulWidget {
  final String driverName;
  final String? driverProfilePicture;
  final double driverRating;
  final int driverTotalReviews;
  final String carBrand;
  final String carModel;
  final String licensePlateNumber;
  final String? licensePlatePicture;
  final String bidAmount;
  final String tripDistance;
  final String pickUpAddress;
  final String destinationAddress;
  final String rideId;
  final String driverId;

  const BookingCarsBottomSheet({
    Key? key,
    this.driverName = '',
    this.driverProfilePicture,
    this.driverRating = 0.0,
    this.driverTotalReviews = 0,
    this.carBrand = '',
    this.carModel = '',
    this.licensePlateNumber = '',
    this.licensePlatePicture,
    this.bidAmount = '',
    this.tripDistance = '',
    this.pickUpAddress = '',
    this.destinationAddress = '',
    required this.rideId,
    this.driverId = '',
  }) : super(key: key);

  @override
  _BookingCarsBottomSheetState createState() => _BookingCarsBottomSheetState();
}

class _BookingCarsBottomSheetState extends State<BookingCarsBottomSheet> {
  int rating = 0;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initRidePickedUpListener();
  }

  @override
  void dispose() {
    _logger.i('Disposing BookingCarsBottomSheet, removing ride-picked-up listener');
    SocketIoService.to.offRidePickedUp();
    super.dispose();
  }

  Future<void> _initRidePickedUpListener() async {
    final socketService = SocketIoService.to;

    // Ensure socket is connected before setting up listener
    if (!socketService.isConnected.value) {
      _logger.i('Socket not connected for ride-picked-up, connecting...');
      await socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _logger.i('Setting up listener for ride-picked-up event in BookingCarsBottomSheet');

    // Listen for ride-picked-up event (driver has arrived and picked up passenger)
    socketService.onRidePickedUp((data) {
      _logger.i('Received ride-picked-up event in BookingCarsBottomSheet: $data');

      if (mounted) {
        // Driver has picked up passenger — switch polyline from pickup to destination
        final pickUpController = Get.find<PickUpLocationController>();
        final destLat = double.tryParse(pickUpController.destinationLatitudeController.text) ?? 0.0;
        final destLng = double.tryParse(pickUpController.destinationLongitudeController.text) ?? 0.0;
        if (destLat != 0.0 || destLng != 0.0) {
          Get.find<HomePageController>().startRideToDestinationTracking(LatLng(destLat, destLng));
        } else {
          Get.find<HomePageController>().stopDriverLocationTracking();
        }

        Get.find<HomePageController>().showPassengerSheet(
          (_) => DriverArrivedBottomSheet(
            driverName: widget.driverName,
            driverProfilePicture: widget.driverProfilePicture,
            driverRating: widget.driverRating,
            driverTotalReviews: widget.driverTotalReviews,
            carBrand: widget.carBrand,
            carModel: widget.carModel,
            licensePlateNumber: widget.licensePlateNumber,
            licensePlatePicture: widget.licensePlatePicture,
            bidAmount: widget.bidAmount,
            tripDistance: widget.tripDistance,
            pickUpAddress: widget.pickUpAddress,
            destinationAddress: widget.destinationAddress,
            rideId: widget.rideId,
            driverId: widget.driverId,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use dynamic data from socket payload
    // final displayName = widget.driverName.isNotEmpty ? widget.driverName : 'John Doe';
    final displayName = widget.driverName;
    // final displayImageUrl = widget.driverProfilePicture ?? 'https://picsum.photos/250?image=9';
    final displayImageUrl = widget.driverProfilePicture ?? '';
    // final displayRating = widget.driverRating > 0 ? widget.driverRating : 3.54;
    final displayRating = widget.driverRating;
    // final displayTrips = widget.driverTotalReviews > 0 ? widget.driverTotalReviews : 3;
    final displayTrips = widget.driverTotalReviews;
    // final displayPrice = widget.bidAmount.isNotEmpty ? '€${widget.bidAmount}' : '€24';
    final displayPrice = widget.bidAmount.isNotEmpty ? formatPrice(widget.bidAmount) : '';
    // final displayDistance = widget.tripDistance.isNotEmpty ? '${widget.tripDistance} km' : '28 km';
    final displayDistance = widget.tripDistance.isNotEmpty ? '${widget.tripDistance} km' : '';
    // final displayCarTitle = widget.licensePlateNumber.isNotEmpty ? widget.licensePlateNumber : 'DHK METRO - 8475Dkk';
    final displayCarTitle = widget.licensePlateNumber;
    // final displayCarSubtitle = (widget.carBrand.isNotEmpty || widget.carModel.isNotEmpty) ? '${widget.carBrand} ${widget.carModel}'.trim() : 'Toyota';
    final displayCarSubtitle = (widget.carBrand.isNotEmpty || widget.carModel.isNotEmpty)
        ? '${widget.carBrand} ${widget.carModel}'.trim()
        : '';
    // final displayDestination = widget.destinationAddress.isNotEmpty ? widget.destinationAddress : 'Green Road, Dhaka';
    final displayDestination = widget.destinationAddress;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      color: AppColors.white,
        padding: EdgeInsets.only(top: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          DriverStatusWidget(
            statusText: l10n.driverOnTheWayToPickUp,
            time: '1 min',
            circleColor: Colors.green,
          ),

         // SizedBox(height: 16.sp),
          CarDetailsWidget(
            title: displayCarTitle,
            subtitle: displayCarSubtitle,
            imagePath: widget.licensePlatePicture ?? AppImage.carsSideView,
            backgroundColor: AppColors.violetShade,
            isNetworkImage: widget.licensePlatePicture != null && widget.licensePlatePicture!.isNotEmpty,
          ),
          SizedBox(height: 16.sp),
          /// User Info Section with Avatar and Rating
          UserInfoSection(
            imageUrl: displayImageUrl,
            name: displayName,
            rating: displayRating,
            trips: displayTrips,
            profession: AppLocalization.tr.professionalLabel,
            price: displayPrice,
            distance: displayDistance,
          ),
         // SupportNoteWidget(),
          Padding(
            padding:  EdgeInsets.all(8.0),
            child: Text(l10n.yourTrip,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.sp),),
          ),
          Padding(
            padding:  EdgeInsets.all(5.sp),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primaryColor),
                SizedBox(width: 5.sp),
                Expanded(
                  child: Text(
                    displayDestination,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          CustomHorizontalLine(thickness: 5.sp,),

          SizedBox(height: 8.sp),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset(AppImage.wallet),
                SizedBox(width: 2.sp,),
                GestureDetector(
                  onTap:() {Get.to(PassengerPaymentScreen(rideId: widget.rideId, driverId: widget.driverId));},
                    child: Text(AppLocalization.tr.payViaWalletLabel,style: TextStyle(fontSize: 20.sp),
                    )
                )
              ],
            ),
          ),
          SupportNoteWidget(
            conversationId: widget.rideId,
            userName: displayName,
            userStatus: AppLocalization.tr.driverLabel,
          ),
          CustomHorizontalLine(thickness: 5.sp,),

          TripIdWidget(tripId: widget.rideId),
          CustomHorizontalLine(thickness: 5.sp,),
          // Cancel Button
          // CancelDriverWidget(
          //   onCancelPressed: () {
          //     Get.to(() => CancelTaxiScreen());
          //   },
          // ),

        ],
      ),
    );
  }
}
