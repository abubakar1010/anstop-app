import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/location_service.dart';
import 'package:ride_sharing/services/logger.dart';
import 'package:ride_sharing/services/map_camera_mixin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/feature/passenger/car_booking/service/ride_request_service.dart';

import 'package:ride_sharing/services/app_config.dart';

class PickUpLocationController extends GetxController with MapCameraMixin {
  final _logger = logger(PickUpLocationController);

  final TextEditingController locationTEController = TextEditingController();

  // Pickup location controllers
  final TextEditingController pickUpAddressController = TextEditingController();
  final TextEditingController pickUpLatitudeController = TextEditingController();
  final TextEditingController pickUpLongitudeController = TextEditingController();

  // Destination location controllers
  final TextEditingController destinationAddressController = TextEditingController();
  final TextEditingController destinationLatitudeController = TextEditingController();
  final TextEditingController destinationLongitudeController = TextEditingController();

  Position? currentPosition;
  bool isLoading = true;
  bool isCalculatingFare = false;
  Set<Marker> markers = {};

  // Fare, distance and duration (all returned by the calculateFare API)
  double calculatedDistance = 0.0;
  double calculatedFare = 0.0;
  double calculatedDuration = 0.0;

  // Ride for
  String rideFor = 'SELF';
  final TextEditingController friendPhoneController = TextEditingController();

  void setRideFor(String value) {
    rideFor = value;
    update();
  }

  final RideRequestService _rideRequestService = RideRequestService();

  @override
  void onInit() {
    super.onInit();
    _debugGooglePlacesApi();
    _initializeMap();
  }

  Future<void> _debugGooglePlacesApi() async {
    const testInput = 'Paris';
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$testInput&key=${AppConfig.googleMapsApiKey}&language=en',
    );
    try {
      final response = await http.get(uri);
      final decoded = jsonDecode(response.body);
      _logger.i('Places API status: ${decoded['status']}');
      if (decoded['error_message'] != null) {
        _logger.e('Places API error_message: ${decoded['error_message']}');
      }
      _logger.d('Places API raw response: ${response.body}');
    } catch (e) {
      _logger.e('Places API debug call failed: $e');
    }
  }

  Future<void> _initializeMap() async {
    final LocationAccess access = await LocationService.requestAccess();
    if (access != LocationAccess.granted) {
      isLoading = false;
      update();
      await LocationService.showAccessDialog(access);
      return;
    }
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final Position? position = await LocationService.readPosition();

    isLoading = false;
    if (position == null) {
      update();
      return;
    }

    try {
      currentPosition = position;

      // Pre-fill pickup with current GPS location as default
      pickUpLatitudeController.text = position.latitude.toString();
      pickUpLongitudeController.text = position.longitude.toString();

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.name, p.street, p.locality]
              .where((s) => s != null && s.isNotEmpty)
              .toSet()
              .toList();
          pickUpAddressController.text = parts.isNotEmpty
              ? parts.join(', ')
              : 'Current Location';
        } else {
          pickUpAddressController.text = 'Current Location';
        }
      } catch (_) {
        pickUpAddressController.text = 'Current Location';
      }

      markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: AppLocalization.tr.yourLocationMarker),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      update();

      moveCameraTo(LatLng(position.latitude, position.longitude));
    } catch (e) {
      _logger.e('Failed to apply current location: $e');
      update();
    }
  }

  // Calculate distance between two coordinates using Haversine formula
  double calculateDistanceInKm(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return double.parse(distance.toStringAsFixed(1));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Check if both locations are set
  bool areLocationsSet() {
    return pickUpLatitudeController.text.isNotEmpty &&
        pickUpLongitudeController.text.isNotEmpty &&
        destinationLatitudeController.text.isNotEmpty &&
        destinationLongitudeController.text.isNotEmpty;
  }

  // Calculate fare from API
  Future<bool> calculateFare() async {
    if (!areLocationsSet()) {
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.selectPickupAndDestinationMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isCalculatingFare = true;
    update();

    try {
      final double pickUpLat = double.parse(pickUpLatitudeController.text);
      final double pickUpLng = double.parse(pickUpLongitudeController.text);
      final double destLat = double.parse(destinationLatitudeController.text);
      final double destLng = double.parse(destinationLongitudeController.text);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      final response = await _rideRequestService.calculateFare(
        pickUpLat: pickUpLat,
        pickUpLng: pickUpLng,
        destinationLat: destLat,
        destinationLng: destLng,
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        calculatedFare = (data['fare'] as num).toDouble();
        calculatedDistance = (data['distance'] as num).toDouble();
        calculatedDuration = (data['duration'] as num).toDouble();
        isCalculatingFare = false;
        update();
        return true;
      } else {
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
        isCalculatingFare = false;
        update();
        return false;
      }
    } catch (e) {
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        'Failed to calculate fare: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      isCalculatingFare = false;
      update();
      return false;
    }
  }

  // Create ride request — returns null on success, error message string on failure
  Future<String?> createRideRequest({
    required double preferedFare,
    required String note,
    required List<String> rideNeeds,
    required String paymentMethod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      final body = {
        'pickUp': {
          'name': pickUpAddressController.text,
          // 'latitude': 0,
          // 'longitude': 0
          'latitude': double.parse(pickUpLatitudeController.text),
          'longitude': double.parse(pickUpLongitudeController.text),
        },
        'destination': {
          'name': destinationAddressController.text,
          'latitude': double.parse(destinationLatitudeController.text),
          'longitude': double.parse(destinationLongitudeController.text),
        },
       // 'distance': calculatedDistance.toString(),
       // 'baseFare': calculatedFare,
       // 'preferedFare': preferedFare,
        'note': note,
        'rideNeeds': rideNeeds,
        'paymentMethod': paymentMethod,
        'rideFor': rideFor,
        if (rideFor == 'OTHER') 'riderNumber': friendPhoneController.text,
      };

      final response = await _rideRequestService.createRideRequest(
        body: body,
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        return null;
      } else {
        return response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to create ride request';
      }
    } catch (e) {
      return 'Failed to create ride request: $e';
    }
  }

  // Update markers on map
  void updateMapMarkers() {
    markers.clear();

    if (pickUpLatitudeController.text.isNotEmpty && pickUpLongitudeController.text.isNotEmpty) {
      markers.add(
        Marker(
          markerId: MarkerId('pickup_location'),
          position: LatLng(
            double.parse(pickUpLatitudeController.text),
            double.parse(pickUpLongitudeController.text),
          ),
          infoWindow: InfoWindow(title: 'Prise en charge : ${pickUpAddressController.text}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    if (destinationLatitudeController.text.isNotEmpty && destinationLongitudeController.text.isNotEmpty) {
      markers.add(
        Marker(
          markerId: MarkerId('destination_location'),
          position: LatLng(
            double.parse(destinationLatitudeController.text),
            double.parse(destinationLongitudeController.text),
          ),
          infoWindow: InfoWindow(title: 'Destination : ${destinationAddressController.text}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    update();
  }

  @override
  void onClose() {
    disposeMapController();
    pickUpAddressController.dispose();
    pickUpLatitudeController.dispose();
    pickUpLongitudeController.dispose();
    destinationAddressController.dispose();
    destinationLatitudeController.dispose();
    destinationLongitudeController.dispose();
    friendPhoneController.dispose();
    super.onClose();
  }
}
