import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/feature/wallet/data/transaction_model.dart';
import 'package:ride_sharing/services/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/feature/wallet/service/wallet_service.dart';
import 'package:ride_sharing/services/stripe/stripe_helper.dart';
import 'package:ride_sharing/services/stripe/stripe_config.dart';

import '../../../services/api_client.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class WalletController extends GetxController {
  // ==================== Services ====================
  final WalletService _walletService = WalletService();
  final Logger logger = Logger();
  final ApiClient _apiClient = ApiClient();

  // ==================== Text Controllers ====================
  final TextEditingController amountTEController = TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();

  late StripePaymentHelper _stripeHelper;
  final transactions = <TransactionModel>[].obs;
  final RxInt balance = 0.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _initStripe();
  }

  @override
  void onClose() {
    amountTEController.dispose();
    super.onClose();
  }

  // ==================== Stripe Initialization ====================
  void _initStripe() {
    final stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

    _stripeHelper = StripePaymentHelper(
      config: StripeConfig(
        secretKey: stripeSecretKey,
        merchantDisplayName: 'Ride Sharing App',
      ),
      onPaymentSuccess: (result) {
        print('Payment successful: ${result.paymentData}');
      },
      onPaymentFailure: (result) {
        print('Payment failed: ${result.message}');
      },
      onLog: (message) {
        print('[Stripe] $message');
      },
    );
  }

  // ==================== Business Logic ====================
  Future<void> processDeposit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final amount = double.tryParse(amountTEController.text.trim()) ?? 0;
      if (amount <= 0) {
        errorMessage.value = 'Please enter a valid amount';
        return;
      }

      // Process Stripe payment
      final paymentResult = await _stripeHelper.processPayment(
        context: context,
        amount: amount,
        currency: 'USD',
        description: 'Wallet Deposit',
        showSuccessDialog: false,
      );

      if (paymentResult.isSuccess && paymentResult.paymentData != null) {
        // Get transaction ID from Stripe response
        final transactionId = paymentResult.paymentData!['id'] as String;
        final amountInCents = paymentResult.paymentData!['amount'] as int;

        // Call backend API to record transaction
        await _recordTransaction(
          transactionId: transactionId,
          amount: amountInCents ~/ 100, // Convert cents to dollars
        );
      } else {
        errorMessage.value = paymentResult.message ?? 'Payment failed';
      }
    } catch (e) {
      debugPrint('wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _recordTransaction({
    required String transactionId,
    required int amount,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        errorMessage.value = 'Not authenticated';
        return;
      }

      final response = await _walletService.createTransaction(
        accessToken: accessToken,
        transactionId: transactionId,
        amount: amount,
        type: 'DEPOSIT',
      );

      if (response.isSuccess) {
        Get.snackbar(
          AppLocalization.tr.successTitle,
          AppLocalization.tr.depositCompletedMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate back with success result
        Get.back(result: true);
      } else {
        debugPrint('wallet_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    }
  }

  // ==================== Validation ====================
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.amountRequiredError;
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return AppLocalization.tr.invalidAmountError;
    }
    return null;
  }

  // ==================== Fetch Transactions ====================
  Future<void> getTransactions({int page = 1, int limit = 10}) async {


    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        const msg = 'Not authenticated';
        errorMessage.value = msg;
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final result = await _walletService.getTransactions(

        accessToken: accessToken,
        page: page,
        limit: limit,
      );

      transactions.assignAll(result);

      logger.i('✅ Transactions fetched: ${result.length}');
    } catch (e) {
      final msg = e.toString();
      errorMessage.value = msg;

      logger.e(e);

      Get.snackbar(
        AppLocalization.tr.errorTitle,
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) return;

      final response = await _apiClient.getRequest(
        ApiUrls.getBalance, // {{base-url}}/users/balance
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        balance.value = response.responseData['data']['balance'] ?? 0;
      } else {
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ==================== Withdrawal Request ====================
  Future<bool> createWithdrawalRequest({
    required int amount,
    required String bankName,
    required String accountNumber,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        errorMessage.value = 'Not authenticated';
        return false;
      }

      final response = await _walletService.createWithdrawalRequest(
        accessToken: accessToken,
        amount: amount,
        bankName: bankName,
        accountNumber: accountNumber,
      );

      if (response.isSuccess) {
        // Refresh balance after withdrawal request
        await getBalance();
        await getTransactions();
        return true;
      } else {
        debugPrint('wallet_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
