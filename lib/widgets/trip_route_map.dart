import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/feature/passenger/trip_details/data/get_trip_details_model.dart';

/// A small, non-interactive map of a past or current trip: one marker at the
/// pick-up, one at the drop-off, framed so both are visible.
class TripRouteMap extends StatelessWidget {
  const TripRouteMap({
    super.key,
    required this.pickup,
    required this.destination,
    this.height = 180,
  });

  final LocationInfo pickup;
  final LocationInfo destination;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (!pickup.hasPosition || !destination.hasPosition) {
      return const SizedBox.shrink();
    }
    final from = LatLng(pickup.latitude, pickup.longitude);
    final to = LatLng(destination.latitude, destination.longitude);

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng((from.latitude + to.latitude) / 2, (from.longitude + to.longitude) / 2),
            zoom: 12,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('pickup'),
              position: from,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
            Marker(markerId: const MarkerId('destination'), position: to),
          },
          onMapCreated: (controller) {
            // Wait a frame: fitting bounds before the map has a size throws.
            // The screen may also be gone by then, which is fine to ignore.
            Future.delayed(const Duration(milliseconds: 300), () async {
              try {
                await controller.moveCamera(CameraUpdate.newLatLngBounds(_bounds(from, to), 40));
              } catch (_) {}
            });
          },
          liteModeEnabled: true,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  static LatLngBounds _bounds(LatLng a, LatLng b) => LatLngBounds(
        southwest: LatLng(math.min(a.latitude, b.latitude), math.min(a.longitude, b.longitude)),
        northeast: LatLng(math.max(a.latitude, b.latitude), math.max(a.longitude, b.longitude)),
      );
}
