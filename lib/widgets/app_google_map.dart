import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/services/location_service.dart';
import 'package:ride_sharing/services/map_camera_mixin.dart';

/// The one map surface every screen renders.
///
/// [camera] is passed in rather than looked up, because a map that finds its
/// own controller ends up driving the wrong one: the pick-up screen used to
/// render the home screen's map, so `PickUpLocationController` never received
/// a [GoogleMapController] and its camera could never leave the fallback.
class AppGoogleMap extends StatelessWidget {
  const AppGoogleMap({
    super.key,
    required this.camera,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
  });

  final MapCameraMixin camera;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      // Seeded from the last position this device reported, so a cold start
      // opens where the user actually is instead of a hardcoded city.
      initialCameraPosition: LocationService.initialCamera,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      markers: markers,
      polylines: polylines,
      circles: circles,
      onMapCreated: camera.attachMapController,
    );
  }
}
