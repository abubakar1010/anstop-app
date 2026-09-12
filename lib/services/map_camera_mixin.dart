import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/services/location_service.dart';

/// Owns a screen's [GoogleMapController] and every camera move made through it.
///
/// Camera moves and map creation race each other: a fix that arrives before
/// `onMapCreated` had nowhere to go, and each screen worked around it by
/// re-reading `currentPosition` inside `onMapCreated` — a workaround that was
/// missing on some screens and wrong on others. Here a move requested too
/// early is remembered and replayed the moment the map exists, so no update
/// can be dropped whichever order the two arrive in.
mixin MapCameraMixin on GetxController {
  GoogleMapController? mapController;

  CameraPosition? _pendingCamera;

  /// Wire this straight to `GoogleMap.onMapCreated`.
  void attachMapController(GoogleMapController controller) {
    mapController = controller;

    final CameraPosition? pending = _pendingCamera;
    _pendingCamera = null;
    if (pending != null) {
      controller.animateCamera(CameraUpdate.newCameraPosition(pending));
    }
  }

  /// Centres the map on [target], setting [zoom].
  void moveCameraTo(LatLng target, {double zoom = LocationService.defaultZoom}) {
    final CameraPosition camera = CameraPosition(target: target, zoom: zoom);
    final GoogleMapController? controller = mapController;
    if (controller == null) {
      _pendingCamera = camera;
      return;
    }
    controller.animateCamera(CameraUpdate.newCameraPosition(camera));
  }

  /// Pans to [target] while leaving the user's zoom alone — for following a
  /// moving position rather than jumping to a new place.
  void followCameraTo(LatLng target) {
    final GoogleMapController? controller = mapController;
    if (controller == null) {
      _pendingCamera = CameraPosition(
        target: target,
        zoom: LocationService.defaultZoom,
      );
      return;
    }
    controller.animateCamera(CameraUpdate.newLatLng(target));
  }

  void disposeMapController() {
    mapController?.dispose();
    mapController = null;
    _pendingCamera = null;
  }
}
