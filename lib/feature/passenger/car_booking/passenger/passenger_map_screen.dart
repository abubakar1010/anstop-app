import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/find_car_bottom_sheet.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/feature/passenger/passenger_common_utils/custom_google_map.dart';

class PassengerMapScreen extends StatefulWidget {
  final String pickUpAddress;
  final String destinationAddress;
  final double distance;
  final double fare;
  final double duration;

  const PassengerMapScreen({
    Key? key,
    required this.pickUpAddress,
    required this.destinationAddress,
    required this.distance,
    required this.fare,
    required this.duration,
  }) : super(key: key);

  @override
  State<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends State<PassengerMapScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<HomePageController>().rideRequestActive = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<HomePageController>().showPassengerSheet(
        (_) => FindCarBottomSheet(
          pickUpAddress: widget.pickUpAddress,
          destinationAddress: widget.destinationAddress,
          distance: widget.distance,
          fare: widget.fare,
          duration: widget.duration,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Back must leave the screen, not just close the sheet: on its own the
    // sheet would close and strand the user on a bare map with no controls.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final homeController = Get.find<HomePageController>();
        if (homeController.rideRequestActive) return;
        homeController.closeCurrentSheet();
        homeController.clearDestinationRadiusCircle();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        key: Get.find<HomePageController>().scaffoldKey,
        body: const PassengerGoogleMapWidget(),
      ),
    );
  }
}
