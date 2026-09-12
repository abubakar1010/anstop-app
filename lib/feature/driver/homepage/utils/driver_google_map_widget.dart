import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/feature/driver/homepage/controller/driver_home_controller.dart';
import 'package:ride_sharing/widgets/app_google_map.dart';

class DriverGoogleMapWidget extends StatelessWidget {
  const DriverGoogleMapWidget({Key? key}) : super(key: key);

  static final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverHomeScreenController>(
      builder: (controller) {
        // Log current state for debugging
        _logger.i('DriverGoogleMapWidget rebuild - markers: ${controller.markers.length}, polylines: ${controller.polylines.value.length}');

        return AppGoogleMap(
          camera: controller,
          markers: controller.markers,
          polylines: controller.polylines.value,
          circles: controller.circles,
        );
      },
    );
  }
}
