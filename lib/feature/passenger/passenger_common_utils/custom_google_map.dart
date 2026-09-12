import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/widgets/app_google_map.dart';

/// The home/ride map, driven by [HomePageController]. Screens with their own
/// map state build [AppGoogleMap] with their own controller instead.
class PassengerGoogleMapWidget extends StatelessWidget {
  const PassengerGoogleMapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomePageController>(
      builder: (controller) {
        return AppGoogleMap(
          camera: controller,
          markers: controller.markers,
          polylines: controller.polylines,
          circles: controller.circles,
        );
      },
    );
  }
}
