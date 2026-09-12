import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CancelTaxiController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController otherReasonTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<String> selectedReasons = <String>[].obs;
  final RxString errorMessage = ''.obs;

  final List<String> cancellationReasons = [
    'Driver is taking too long',
    'Found another ride',
    'Change of plans',
    'Wrong pickup location',
    'Driver requested to cancel',
    'Other',
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

      // TODO: Implement actual cancellation API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate back with cancellation confirmed
      // Get.back(result: true);

    } catch (e) {
      debugPrint('cancel_taxi_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  bool validateCancellation() {
    if (selectedReasons.isEmpty) {
      errorMessage.value = 'Please select at least one reason';
      return false;
    }

    if (selectedReasons.contains('Other') && otherReasonTEController.text.isEmpty) {
      errorMessage.value = 'Please specify other reason';
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
    // Get.back();
  }
}
