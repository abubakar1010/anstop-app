import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class DriverTripFlowController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final Rx<dynamic> currentTrip = Rx<dynamic>(null);
  final RxString tripStatus = 'pending'.obs; // pending, accepted, started, arrived, completed
  final Rx<LatLng?> driverLocation = Rx<LatLng?>(null);
  final Rx<LatLng?> passengerLocation = Rx<LatLng?>(null);
  final RxString errorMessage = ''.obs;
  GoogleMapController? mapController;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadTripData();
    _trackLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  void _loadTripData() {
    // Get trip data from arguments if passed
    if (Get.arguments != null) {
      currentTrip.value = Get.arguments;
      tripStatus.value = Get.arguments['status'] ?? 'pending';
    }
  }

  void _trackLocation() {
    // TODO: Implement real-time location tracking
    // Update driverLocation periodically and send to server
  }

  Future<void> acceptTrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement accept trip API call
      await Future.delayed(const Duration(seconds: 1));

      tripStatus.value = 'accepted';

      AppSnackbar.snackbar(
        AppLocalization.tr.tripAcceptedTitle,
        AppLocalization.tr.navigateToPassengerMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      debugPrint('driver_trip_flow_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectTrip() async {
    try {
      isLoading.value = true;

      // TODO: Implement reject trip API call
      await Future.delayed(const Duration(seconds: 1));

      // Get.back();

    } catch (e) {
      debugPrint('driver_trip_flow_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startTrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement start trip API call
      await Future.delayed(const Duration(seconds: 1));

      tripStatus.value = 'started';

    } catch (e) {
      debugPrint('driver_trip_flow_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> arrivedAtPickup() async {
    try {
      isLoading.value = true;

      // TODO: Implement arrived notification API call
      await Future.delayed(const Duration(seconds: 1));

      tripStatus.value = 'arrived';

      AppSnackbar.snackbar(
        AppLocalization.tr.arrivedTitle,
        AppLocalization.tr.passengerNotifiedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      debugPrint('driver_trip_flow_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeTrip() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement complete trip API call
      await Future.delayed(const Duration(seconds: 1));

      tripStatus.value = 'completed';

      // Show payment dialog or navigate to completion screen
      _showCompletionDialog();

    } catch (e) {
      debugPrint('driver_trip_flow_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  void _showCompletionDialog() {
    // TODO: Show trip completion dialog with payment details
  }

  void updateLocation(LatLng location) {
    driverLocation.value = location;
    // TODO: Send location update to server
  }

  void contactPassenger() {
    // TODO: Implement contact passenger functionality
  }

  void navigateToPassenger() {
    // TODO: Open navigation app with passenger location
  }

  void cancelTrip() {
    // TODO: Navigate to cancellation screen or show dialog
  }
}
