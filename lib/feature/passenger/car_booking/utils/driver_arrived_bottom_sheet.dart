import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/car_details.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/driver_status_widget.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/ride_begun_bottom_sheet.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/utils/user_info_section.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/payment/view/passenger_payment_screen.dart';

import '../../../../app/utils/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class DriverArrivedBottomSheet extends StatefulWidget {
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

  const DriverArrivedBottomSheet({
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
    this.rideId = '',
    this.driverId = '',
  }) : super(key: key);

  @override
  _DriverArrivedBottomSheetState createState() => _DriverArrivedBottomSheetState();
}

class _DriverArrivedBottomSheetState extends State<DriverArrivedBottomSheet> {
  int rating = 0;
  final Logger _logger = Logger();
  String? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _initRideCompletedListener();
  }

  @override
  void dispose() {
    _logger.i('Disposing DriverArrivedBottomSheet, removing ride-completed listener');
    SocketIoService.to.offRideCompleted();
    super.dispose();
  }

  Future<void> _initRideCompletedListener() async {
    final socketService = SocketIoService.to;

    // Ensure socket is connected before setting up listener
    if (!socketService.isConnected.value) {
      _logger.i('Socket not connected for ride-completed, connecting...');
      await socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _logger.i('Setting up listener for ride-completed event in DriverArrivedBottomSheet');

    // Listen for ride-completed event
    socketService.onRideCompleted((data) {
      _logger.i('Received ride-completed event in DriverArrivedBottomSheet: $data');

      if (mounted && data != null && data is Map<String, dynamic>) {
        final paymentMethod = data['paymentMethod'] as String? ?? '';
        final eventRideId = data['rideId'] as String? ?? '';
        final rideId = widget.rideId.isNotEmpty ? widget.rideId : eventRideId;
        final eventDriverId = data['driverId'] as String? ?? '';
        final driverId = widget.driverId.isNotEmpty ? widget.driverId : eventDriverId;
        _logger.i('Payment method from ride-completed: $paymentMethod, rideId: $rideId (widget: ${widget.rideId}, event: $eventRideId), driverId: $driverId');

        Get.find<HomePageController>().closeCurrentSheet();
        Get.offAll(() => PassengerPaymentScreen(
          driverName: widget.driverName,
          driverProfilePicture: widget.driverProfilePicture,
          driverRating: widget.driverRating,
          driverTotalReviews: widget.driverTotalReviews,
          bidAmount: widget.bidAmount,
          tripDistance: widget.tripDistance,
          pickUpAddress: widget.pickUpAddress,
          destinationAddress: widget.destinationAddress,
          paymentMethod: paymentMethod,
          rideId: rideId,
          driverId: driverId,
        ));
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.only(top: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          DriverStatusWidget(
            statusText:  l10n.driverHasArrived,
            circleColor: Colors.green,
          ),

          // SizedBox(height: 16.sp),
          CarDetailsWidget(
            title: displayCarTitle,
            subtitle: displayCarSubtitle,
            imagePath: widget.licensePlatePicture ?? AppImage.carsSideView,
            backgroundColor: AppColors.greenShade50,
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
          SizedBox(height: 16.sp),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal:  16.sp),
            child: CustomButton(
              onPressed: () {
                Get.find<HomePageController>().showPassengerSheet(
                  (_) => RideBegunBottomSheet(
                    driverName: widget.driverName,
                    driverProfilePicture: widget.driverProfilePicture,
                    driverRating: widget.driverRating,
                    driverTotalReviews: widget.driverTotalReviews,
                    bidAmount: widget.bidAmount,
                    tripDistance: widget.tripDistance,
                    destinationAddress: widget.destinationAddress,
                  ),
                );
              },
              title: Text(
                l10n.letsRide,
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
