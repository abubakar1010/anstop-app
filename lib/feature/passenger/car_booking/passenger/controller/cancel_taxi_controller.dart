import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/ride_session_controller.dart';

/// Cancels a ride with the reasons the user picked. Used by riders and by
/// drivers; the server decides whether the ride can still be cancelled.
class CancelTaxiController extends GetxController {
  /// The ride to cancel. When null, the ride currently in progress is used.
  final String? rideId;
  final bool asDriver;

  CancelTaxiController({this.rideId, this.asDriver = false});

  // ==================== Text Controllers ====================
  final TextEditingController otherReasonTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<String> selectedReasons = <String>[].obs;
  final RxString errorMessage = ''.obs;

  late final List<String> cancellationReasons = asDriver
      ? [
          AppLocalization.tr.cancelReasonRiderNoShow,
          AppLocalization.tr.cancelReasonRiderRequested,
          AppLocalization.tr.cancelReasonVehicleProblem,
          AppLocalization.tr.cancelReasonChangeOfPlans,
          AppLocalization.tr.cancelReasonOther,
        ]
      : [
          AppLocalization.tr.cancelReasonDriverTooLong,
          AppLocalization.tr.cancelReasonFoundAnother,
          AppLocalization.tr.cancelReasonChangeOfPlans,
          AppLocalization.tr.cancelReasonWrongPickup,
          AppLocalization.tr.cancelReasonDriverRequested,
          AppLocalization.tr.cancelReasonOther,
        ];

  bool get isOtherSelected => selectedReasons.contains(AppLocalization.tr.cancelReasonOther);

  // ==================== Lifecycle ====================
  @override
  void onClose() {
    otherReasonTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  void selectReason(String reason) {
    errorMessage.value = '';
    if (selectedReasons.contains(reason)) {
      selectedReasons.remove(reason);
    } else {
      selectedReasons.add(reason);
    }
  }

  bool isReasonSelected(String reason) {
    return selectedReasons.contains(reason);
  }

  /// Returns true once the server has cancelled the ride.
  Future<bool> submitCancellation() async {
    if (isLoading.value || !validateCancellation()) {
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final id = rideId ?? RideSessionController.to.ride.value?.rideId;
      if (id == null || id.isEmpty) {
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        return false;
      }
      final reason = [
        ...selectedReasons.where((r) => r != AppLocalization.tr.cancelReasonOther),
        if (otherReasonTEController.text.trim().isNotEmpty)
          otherReasonTEController.text.trim(),
      ].join('; ');
      final ack = await RideSessionController.to.cancelRide(id, reason);
      if (!ack.ok) {
        debugPrint('cancel_taxi_controller: ${ack.code}');
        // The ride moved on (picked up, already cancelled, ...) meanwhile.
        errorMessage.value = ack.code == 'RIDE_INVALID_STATE'
            ? AppLocalization.tr.rideCannotBeCancelledMessage
            : AppLocalization.tr.genericErrorMessage;
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('cancel_taxi_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool validateCancellation() {
    if (selectedReasons.isEmpty) {
      errorMessage.value = AppLocalization.tr.cancellationReasonRequiredError;
      return false;
    }

    if (isOtherSelected && otherReasonTEController.text.trim().isEmpty) {
      errorMessage.value = AppLocalization.tr.cancellationOtherRequiredError;
      return false;
    }

    return true;
  }
}
