import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Why the app does — or doesn't — have a usable GPS fix.
enum LocationAccess { granted, serviceDisabled, denied, deniedForever }

/// Single owner of everything the app knows about where the device is.
///
/// Each map screen used to carry its own copy of the permission dance, its own
/// `getCurrentPosition` call and its own hardcoded fallback city. When any step
/// of that failed the map silently stayed on the fallback, so a passenger in
/// Dhaka was shown Paris. All of it lives here now, with three rules the
/// per-screen copies didn't have: never fall back to a real place the user
/// isn't in, never wait forever for a fix, and never give up on a session just
/// because the first attempt was refused.
class LocationService {
  const LocationService._();

  static const String _latKey = 'lastKnownLatitude';
  static const String _lngKey = 'lastKnownLongitude';

  static const double defaultZoom = 15.0;

  /// Used only until this device has ever produced a fix. A world view reads
  /// as "still locating"; a hardcoded city reads as a wrong location.
  static const CameraPosition worldCamera = CameraPosition(
    target: LatLng(20.0, 0.0),
    zoom: 1.0,
  );

  static LatLng? _lastKnown;

  /// The most recent position the app has seen, across launches.
  static LatLng? get lastKnownLatLng => _lastKnown;

  /// Synchronous seed for `GoogleMap.initialCameraPosition`, so the very first
  /// frame after a cold start already points at the right part of the world.
  static CameraPosition get initialCamera {
    final LatLng? last = _lastKnown;
    if (last == null) return worldCamera;
    return CameraPosition(target: last, zoom: defaultZoom);
  }

  /// Restores [lastKnownLatLng] from disk. Call before `runApp`; it must never
  /// throw, because startup depends on it.
  static Future<void> warmUp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final double? lat = prefs.getDouble(_latKey);
      final double? lng = prefs.getDouble(_lngKey);
      if (lat != null && lng != null) _lastKnown = LatLng(lat, lng);
    } catch (e) {
      debugPrint('LocationService.warmUp: no cached position ($e)');
    }

    // The OS may be holding a fresher fix than the one we stored.
    try {
      if (await Geolocator.isLocationServiceEnabled() && await _isPermitted()) {
        final Position? position = await Geolocator.getLastKnownPosition();
        if (position != null) await remember(position);
      }
    } catch (e) {
      debugPrint('LocationService.warmUp: no OS last-known position ($e)');
    }
  }

  static Future<bool> _isPermitted() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Asks for whatever is still missing — location services on, permission
  /// granted — and reports what stands in the way when something is.
  static Future<LocationAccess> requestAccess() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      switch (permission) {
        case LocationPermission.denied:
          return LocationAccess.denied;
        case LocationPermission.deniedForever:
          return LocationAccess.deniedForever;
        case LocationPermission.always:
        case LocationPermission.whileInUse:
        case LocationPermission.unableToDetermine:
          return LocationAccess.granted;
      }
    } catch (e) {
      debugPrint('LocationService.requestAccess: $e');
      return LocationAccess.denied;
    }
  }

  /// A fix, or null — never a throw and never an indefinite wait. A cold GPS
  /// indoors times out instead of hanging, and falls back to the OS's cached
  /// fix, which is what keeps the map off the fallback camera.
  static Future<Position?> readPosition({
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeLimit,
      );
      await remember(position);
      return position;
    } catch (e) {
      debugPrint(
        'LocationService.readPosition: live fix failed ($e) — trying last known',
      );
    }

    try {
      final Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) await remember(position);
      return position;
    } catch (e) {
      debugPrint('LocationService.readPosition: no last known position ($e)');
      return null;
    }
  }

  /// Live fixes, with every one of them cached for the next cold start.
  static Stream<Position> positionStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    ).map((Position position) {
      unawaited(remember(position));
      return position;
    });
  }

  /// Remembers [position] for [initialCamera] on the next launch.
  static Future<void> remember(Position position) async {
    _lastKnown = LatLng(position.latitude, position.longitude);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, position.latitude);
      await prefs.setDouble(_lngKey, position.longitude);
    } catch (e) {
      debugPrint('LocationService.remember: could not cache position ($e)');
    }
  }

  /// Explains why the map has no position and offers the one action that can
  /// fix it. Does nothing when access was granted, or when no context exists
  /// yet to host a dialog.
  static Future<void> showAccessDialog(LocationAccess access) async {
    final BuildContext? context = Get.context;
    if (context == null || access == LocationAccess.granted) return;

    final l10n = AppLocalization.of(context);

    final bool serviceOff = access == LocationAccess.serviceDisabled;
    final bool blockedInSettings = access == LocationAccess.deniedForever;

    final String title = serviceOff
        ? l10n.locationServiceOffTitle
        : l10n.locationPermissionRequiredTitle;
    final String message = serviceOff
        ? l10n.locationServiceOffMessage
        : blockedInSettings
            ? l10n.locationPermissionDeniedForeverMessage
            : l10n.locationPermissionRequiredMessage;
    final String actionLabel = serviceOff || blockedInSettings
        ? l10n.openSettingsButton
        : l10n.okButton;
    final Future<void> Function() onAction = serviceOff
        ? Geolocator.openLocationSettings
        : blockedInSettings
            ? Geolocator.openAppSettings
            : () async {};

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await onAction();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
