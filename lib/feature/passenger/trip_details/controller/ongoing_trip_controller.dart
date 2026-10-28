import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/cancel_taxi.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/feature/passenger/trip_details/data/get_trip_details_model.dart';
import 'package:ride_sharing/feature/passenger/trip_details/service/trip_details_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class OngoingTripController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final Rx<TripDetailsData?> trip = Rx<TripDetailsData?>(null);
  final Rx<LatLng?> driverLocation = Rx<LatLng?>(null);
  final RxString eta = ''.obs;
  final RxString errorMessage = ''.obs;
  GoogleMapController? mapController;

  // ==================== Services ====================
  final TripDetailsService _tripDetailsService = TripDetailsService();

  // ==================== Parameters ====================
  final String rideId;

  // ==================== Constructor ====================
  OngoingTripController({required this.rideId});

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadTripDetails();
    _trackDriver();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  Future<void> _loadTripDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Call API to get trip details
      final response = await _tripDetailsService.getTripDetails(rideId);

      if (response.isSuccess) {
        // Parse the trip details from response
        final tripDetailsModel = GetTripDetailsModel.fromJson(response.responseData);
        trip.value = tripDetailsModel.data;
      } else {
        debugPrint('ongoing_trip_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      debugPrint('ongoing_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.tripDetailsLoadErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _trackDriver() {
    // TODO: Implement real-time driver location tracking using socket
    // This should update driverLocation and eta
  }

  /// Whether the server would still accept a cancellation from this side:
  /// a rider until pick-up, a driver only once accepted.
  bool canCancel({required bool asDriver}) {
    final status = trip.value?.status;
    return asDriver ? status == 'ACCEPTED' : (status == 'PENDING' || status == 'ACCEPTED');
  }

  /// Asks for a reason, cancels the ride, then leaves the trip screen.
  Future<void> cancelTrip({required bool asDriver}) async {
    final cancelled = await Get.to<bool>(
      () => CancelTaxiScreen(rideId: rideId, asDriver: asDriver),
    );
    if (cancelled != true) return;
    Get.back();
    AppSnackbar.snackbar(
      AppLocalization.tr.successTitle,
      AppLocalization.tr.rideCancelledMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void contactDriver() {
    // TODO: Implement contact driver functionality
    // Could open phone dialer or chat
  }

  void reportIssue() {
    // TODO: Implement report issue functionality
  }
}
