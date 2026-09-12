import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

class PassengerPaymentController extends GetxController {
  // ==================== State ====================
  final RxBool isProcessing = false.obs;
  final RxString selectedMethod = 'cash'.obs;
  final RxDouble amount = 0.0.obs;
  final RxString paymentStatus = 'pending'.obs;
  final RxString errorMessage = ''.obs;

  final List<Map<String, String>> paymentMethods = [
    {'id': 'cash', 'name': 'Cash', 'icon': '💵'},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': '💳'},
    {'id': 'wallet', 'name': 'Wallet', 'icon': '👛'},
    {'id': 'upi', 'name': 'UPI', 'icon': '📱'},
  ];

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadPaymentInfo();
  }

  // ==================== Business Logic ====================
  void _loadPaymentInfo() {
    // Get amount from arguments if passed
    if (Get.arguments != null && Get.arguments is Map) {
      amount.value = Get.arguments['amount'] ?? 0.0;
    }
  }

  void selectPaymentMethod(String methodId) {
    selectedMethod.value = methodId;
  }

  Future<void> processPayment() async {
    if (selectedMethod.value.isEmpty) {
      errorMessage.value = 'Please select a payment method';
      return;
    }

    try {
      isProcessing.value = true;
      errorMessage.value = '';

      // TODO: Implement actual payment processing API call
      await Future.delayed(const Duration(seconds: 2));

      paymentStatus.value = 'completed';

      // Show success and navigate back
      Get.snackbar(
        AppLocalization.tr.successTitle,
        AppLocalization.tr.paymentCompletedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(seconds: 1));
      // Get.back(result: true);

    } catch (e) {
      debugPrint('passenger_payment_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      paymentStatus.value = 'failed';
    } finally {
      isProcessing.value = false;
    }
  }

  void confirmPayment() {
    processPayment();
  }

  // ==================== Navigation ====================
  void goBack() {
    // Get.back();
  }
}
