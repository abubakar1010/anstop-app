import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/ride_session_controller.dart';

class CancelTaxiController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController otherReasonTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<String> selectedReasons = <String>[].obs;
  final RxString errorMessage = ''.obs;

  late final List<String> cancellationReasons = [
    AppLocalization.tr.cancelReasonDriverTooLong,
    AppLocalization.tr.cancelReasonFoundAnother,
    AppLocalization.tr.cancelReasonChangeOfPlans,
    AppLocalization.tr.cancelReasonWrongPickup,
    AppLocalization.tr.cancelReasonDriverRequested,
    AppLocalization.tr.cancelReasonOther,
  ];

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    otherReasonTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  void selectReason(String reason) {
    if (selectedReasons.contains(reason)) {
      selectedReasons.remove(reason);
    } else {
      selectedReasons.add(reason);
    }
  }

  bool isReasonSelected(String reason) {
    return selectedReasons.contains(reason);
  }

  Future<void> submitCancellation() async {
    if (!validateCancellation()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final rideId = RideSessionController.to.ride.value?.rideId;
      if (rideId == null || rideId.isEmpty) {
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        return;
      }
      final reason = [
        ...selectedReasons,
        if (otherReasonTEController.text.trim().isNotEmpty)
          otherReasonTEController.text.trim(),
      ].join('; ');
      final ack = await RideSessionController.to.cancelRide(rideId, reason);
      if (!ack.ok) {
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        return;
      }
      Get.back(result: true);

    } catch (e) {
      debugPrint('cancel_taxi_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  bool validateCancellation() {
    if (selectedReasons.isEmpty) {
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      return false;
    }

    if (selectedReasons.contains(AppLocalization.tr.cancelReasonOther) &&
        otherReasonTEController.text.trim().isEmpty) {
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      return false;
    }

    return true;
  }

  void confirmCancel() {
    // Show confirmation dialog
    submitCancellation();
  }

  // ==================== Navigation ====================
  void goBack() {
    Get.back();
  }
}
