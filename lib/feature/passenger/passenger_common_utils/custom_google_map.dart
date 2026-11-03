import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/widgets/app_google_map.dart';

/// The home/ride map, driven by [HomePageController]. Screens with their own
/// map state build [AppGoogleMap] with their own controller instead.
class PassengerGoogleMapWidget extends StatelessWidget {
  const PassengerGoogleMapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The outer builder answers ordinary update() calls; the inner one also
    // answers update(['map']), which moving cars fire up to 30 times a second,
    // so only the map rebuilds for those.
    return GetBuilder<HomePageController>(
      builder: (_) => GetBuilder<HomePageController>(
        id: 'map',
        builder: (controller) {
          return Stack(
            children: [
              AppGoogleMap(
                camera: controller,
                markers: controller.markers,
                polylines: controller.polylines,
                circles: controller.circles,
                onUserGesture: controller.onUserMovedMap,
              ),
              if (controller.isTrackingDriver && !controller.followDriver)
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_on_driver',
                      tooltip: AppLocalization.tr.recenterOnDriver,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      onPressed: controller.recenterOnDriver,
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
