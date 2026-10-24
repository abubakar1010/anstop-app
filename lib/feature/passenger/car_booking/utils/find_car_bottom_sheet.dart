import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/accept_car_bottom_sheet.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/ride_needs_dropdown.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/controller/pick_up_location_controller.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/services/socket_services.dart';

import '../../../../app/utils/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

class FindCarBottomSheet extends StatefulWidget {
  final String pickUpAddress;
  final String destinationAddress;
  final double distance;
  final double fare;
  final double duration;

  const FindCarBottomSheet({
    Key? key,
    required this.pickUpAddress,
    required this.destinationAddress,
    required this.distance,
    required this.fare,
    required this.duration,
  }) : super(key: key);

  @override
  _FindCarBottomSheetState createState() => _FindCarBottomSheetState();
}

class _FindCarBottomSheetState extends State<FindCarBottomSheet> {
  final TextEditingController descriptionController = TextEditingController();
  final Logger _logger = Logger();

  int childrenCount = 0;
  String _selectedPaymentMethod = 'WALLET';
  List<String> _selectedRideNeeds = [];
  bool _isLoading = false;
  List<dynamic>? _nearbyDriversData;

  final Map<String, String> _paymentMethodMapping = {
    'Wallet': 'WALLET',
    'By Cards': 'CARD',
  };

  @override
  void initState() {
    super.initState();
    _initSocketAndListener();
  }

  Future<void> _initSocketAndListener() async {
    final socketService = SocketIoService.to;
    if (!socketService.isConnected.value) {
      _logger.i('Connecting socket in FindCarBottomSheet...');
      await socketService.connect();
    }
    _logger.i('Socket connection status: ${socketService.isConnected.value}');

    // Set up listener BEFORE making API call
    _logger.i('Setting up nearest-drivers listener in FindCarBottomSheet');
    socketService.onNearestDrivers((data) {
      _logger.i('Received nearest-drivers in FindCarBottomSheet: $data');
      if (data != null) {
        _nearbyDriversData = data is List ? data : (data['data'] as List?);
        _logger.i('Stored ${_nearbyDriversData?.length} drivers');
        if (_nearbyDriversData != null) {
          Get.find<HomePageController>().showNearestDriverMarkers(_nearbyDriversData!);
        }
      }
    });
  }

  @override
  void dispose() {
    // Don't remove listener here if AcceptCarBottomSheet needs it
    super.dispose();
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  Future<void> _onFindCarPressed() async {
    // Show drop-off radius confirmation dialog first
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalization.of(ctx);
        return AlertDialog(
          title: Text(l10n.dropOffNoticeTitle),
          content: Text(l10n.dropOffNoticeMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.dropOffNoticeNo),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.dropOffNoticeYesAccept),
            ),
          ],
        );
      },
    );

    if (accepted != true) return;

    // Show 500m circle on the passenger map
    final pickUpController = Get.find<PickUpLocationController>();
    final destLat = double.tryParse(pickUpController.destinationLatitudeController.text);
    final destLng = double.tryParse(pickUpController.destinationLongitudeController.text);
    if (destLat != null && destLng != null) {
      await Get.find<HomePageController>()
          .showDestinationRadiusCircle(LatLng(destLat, destLng));
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final controller = Get.find<PickUpLocationController>();
      final socketService = SocketIoService.to;

      // Ensure socket is connected
      if (!socketService.isConnected.value) {
        _logger.i('Socket not connected, connecting before API call...');
        await socketService.connect();
      }

      // Clear any previous data
      _nearbyDriversData = null;

      _logger.i('Creating ride request...');

      final error = await controller.createRideRequest(
        preferedFare: widget.fare,
        note: descriptionController.text,
        rideNeeds: _selectedRideNeeds,
        paymentMethod: _selectedPaymentMethod,
      );

      // Wait a moment for socket event to arrive
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        _logger.e('Ride request failed: $error');
        if (mounted) _showErrorSnackbar(context, error);
        return;
      }

      _logger.i('Ride request successful, nearby drivers data: $_nearbyDriversData');
      Get.find<HomePageController>().rideRequestActive = true;
      Get.find<HomePageController>().showPassengerSheet(
        (_) => AcceptCarBottomSheet(
          pickUpAddress: widget.pickUpAddress,
          destinationAddress: widget.destinationAddress,
          initialDriversData: _nearbyDriversData,
        ),
      );
    } catch (e) {
      _logger.e('Error creating ride request: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) _showErrorSnackbar(context, AppLocalization.tr.rideRequestFailedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 345.w,
              child: Card(
                color: AppColors.white,
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalization.tr.yourTripLabel,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      // Pickup Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Image.asset(AppImage.greetings),
                          ),
                          SizedBox(width: 5.sp),
                          Expanded(
                            child: Text(
                              widget.pickUpAddress.isNotEmpty
                                  ? widget.pickUpAddress
                                  : AppLocalization.tr.pickupLocationExample,
                              style: TextStyle(fontSize: 14.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.sp),
                      // Destination Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          SizedBox(width: 5.sp),
                          Expanded(
                            child: Text(
                              widget.destinationAddress.isNotEmpty
                                  ? widget.destinationAddress
                                  : AppLocalization.tr.dropoffLocationExample,
                              style: TextStyle(fontSize: 14.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.sp),
                      // Distance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalization.tr.distanceLabel,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '${widget.distance} km',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalization.tr.durationLabel,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            AppLocalization.tr.durationMinutesLabel((widget.duration / 60).ceil().toString()),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.appGreyColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Fare
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalization.tr.fareLabel,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            formatPrice(widget.fare),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.sp),
            Text(
              AppLocalization.tr.paymentMethodLabel,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.sp),
            // Payment Method Dropdown
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grayShade100),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: DropdownButton<String>(
                value: _paymentMethodMapping.entries
                    .firstWhere((e) => e.value == _selectedPaymentMethod)
                    .key,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                iconSize: 30,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentMethod = _paymentMethodMapping[newValue] ?? 'CASH';
                  });
                },
                underline: Container(),
                dropdownColor: AppColors.white,
                items: <String>['Wallet', 'By Cards']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.sp),
                      child: Row(
                        children: [
                          Image.asset(
                            _getImageForPaymentMethod(value),
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 10),
                          Text(_paymentMethodLabel(value)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10.sp),
            // Ride Needs Dropdown
            Text(
              AppLocalization.tr.addedImportantThingsLabel,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.sp),
            RideNeedsDropdown(
              onSelectionChanged: (selectedItems) {
                setState(() {
                  _selectedRideNeeds = selectedItems;
                });
              },
            ),
            SizedBox(height: 10.sp),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grayShade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: Row(
                  children: [
                    Text(
                      AppLocalization.tr.childrenLabel,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              childrenCount++;
                            });
                          },
                          child: Icon(
                            Icons.keyboard_arrow_up_outlined,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (childrenCount > 0) childrenCount--;
                            });
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$childrenCount',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.sp),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grayShade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: AppLocalization.tr.noteToDriverHint,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20.sp),
            CustomButton(
              height: 50,
              onPressed: _isLoading ? null : _onFindCarPressed,
              title: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalization.tr.findCarButton,
                      style: TextStyle(color: AppColors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentMethodLabel(String paymentMethod) {
    switch (paymentMethod) {
      case 'By Cards':
        return AppLocalization.tr.paymentMethodCard;
      case 'By Cash':
        return AppLocalization.tr.paymentMethodCash;
      default:
        return AppLocalization.tr.paymentMethodWallet;
    }
  }

  String _getImageForPaymentMethod(String paymentMethod) {
    switch (paymentMethod) {
      case 'Wallet':
        return AppImage.wallet;
      case 'By Cards':
        return AppImage.cards;
      case 'By Cash':
        return AppImage.cash;
      default:
        return AppImage.wallet;
    }
  }
}
