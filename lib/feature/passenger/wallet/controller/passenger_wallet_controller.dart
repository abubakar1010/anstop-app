import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class PassengerWalletController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController amountTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxDouble balance = 0.0.obs;
  final RxList<dynamic> transactions = <dynamic>[].obs;
  final RxString selectedAction = ''.obs; // 'add' or 'withdraw'
  final RxString errorMessage = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  @override
  void onClose() {
    amountTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  Future<void> loadWallet() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual API call to load wallet data
      await Future.delayed(const Duration(seconds: 1));


      balance.value = 0.0;
      transactions.value = [];

    } catch (e) {
      debugPrint('passenger_wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;

      // TODO: Implement actual API call to load transactions
      await Future.delayed(const Duration(seconds: 1));

      transactions.value = [];

    } catch (e) {
      debugPrint('passenger_wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  void showAddFundsDialog() {
    selectedAction.value = 'add';
    amountTEController.clear();
  }

  Future<void> addFunds() async {
    final amount = double.tryParse(amountTEController.text);

    if (amount == null || amount <= 0) {
      errorMessage.value = AppLocalization.tr.invalidAmountError;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual add funds API call
      await Future.delayed(const Duration(seconds: 2));

      balance.value += amount;
      amountTEController.clear();

      Get.snackbar(
        AppLocalization.tr.successTitle,
        AppLocalization.tr.fundsAddedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );

      loadTransactions();

    } catch (e) {
      debugPrint('passenger_wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToTransaction(dynamic transaction) {
    // TODO: Show transaction details
  }
}
