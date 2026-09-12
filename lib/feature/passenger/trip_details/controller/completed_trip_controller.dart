import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/trip_details/data/get_trip_details_model.dart';
import 'package:ride_sharing/feature/passenger/trip_details/service/trip_details_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CompletedTripController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController reviewTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final Rx<TripDetailsData?> trip = Rx<TripDetailsData?>(null);
  final RxDouble rating = 0.0.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasSubmittedRating = false.obs;

  // ==================== Services ====================
  final TripDetailsService _tripDetailsService = TripDetailsService();

  // ==================== Parameters ====================
  final String rideId;

  // ==================== Constructor ====================
  CompletedTripController({required this.rideId});

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadTripDetails();
  }

  @override
  void onClose() {
    reviewTEController.dispose();
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
        debugPrint('completed_trip_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      debugPrint('completed_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.tripDetailsLoadErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setRating(double value) {
    rating.value = value;
  }

  Future<void> submitRating() async {
    if (rating.value == 0) {
      errorMessage.value = 'Please provide a rating';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual rating submission API call
      await Future.delayed(const Duration(seconds: 1));

      hasSubmittedRating.value = true;

      // Show success message
      Get.snackbar(
        AppLocalization.tr.successTitle,
        AppLocalization.tr.thankYouForFeedbackMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      debugPrint('completed_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadReceipt() async {
    try {
      isLoading.value = true;

      // TODO: Implement receipt download
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        AppLocalization.tr.successTitle,
        AppLocalization.tr.receiptDownloadedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

    } catch (e) {
      debugPrint('completed_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  void reportIssue() {
    // TODO: Navigate to report screen
  }
}
