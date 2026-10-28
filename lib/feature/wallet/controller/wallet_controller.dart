import 'package:ride_sharing/services/session_controller.dart';
import 'package:flutter/material.dart';
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
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

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
  /// Who is looking: decides whether a ride reads as a cost or as earnings.
  final RxString currentUserId = ''.obs;

  /// Paging of the transaction list: the newest page loads first, older
  /// ones on demand.
  int _transactionsPage = 1;
  final RxBool hasMoreTransactions = false.obs;
  final RxBool isLoadingMoreTransactions = false.obs;
  final RxDouble balance = 0.0.obs;

  // Must match the server's STRIPE_MIN_DEPOSIT / STRIPE_MAX_DEPOSIT, so the
  // user sees the limit before a request is made.
  static const int minimumDeposit = 1;
  static const int maximumDeposit = 1000;

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
    _stripeHelper = StripePaymentHelper(
      config: const StripeConfig(
        merchantDisplayName: 'Anstop',
      ),
      onLog: (message) {
        debugPrint('[Stripe] $message');
      },
    );
  }

  // ==================== Business Logic ====================
  /// Wallet top-up. The server creates the PaymentIntent and credits the
  /// wallet from Stripe's webhook once the money is received; the app only
  /// presents the payment sheet. It never reports a payment as done itself.
  Future<void> processDeposit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final amount = parseAmount(amountTEController.text) ?? 0;
      if (amount <= 0) {
        errorMessage.value = AppLocalization.tr.invalidAmountError;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken() ?? '';
      if (accessToken.isEmpty) {
        errorMessage.value = AppLocalization.tr.sessionExpiredMessage;
        return;
      }

      final intentResponse = await _walletService.createDepositIntent(
        accessToken: accessToken,
        amount: amount,
      );
      final intentData = intentResponse.isSuccess ? intentResponse.responseData['data'] : null;
      final String? clientSecret = intentData?['clientSecret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        debugPrint('wallet_controller: ${intentResponse.errorMessage}');
        throw Exception('Could not create deposit payment');
      }

      final balanceBefore = await _fetchBalance(accessToken);

      if (!context.mounted) return;
      final paymentResult = await _stripeHelper.processPayment(
        context: context,
        clientSecret: clientSecret,
        customerId: intentData?['customerId'] as String?,
        ephemeralKey: intentData?['ephemeralKey'] as String?,
        showSuccessDialog: false,
      );

      if (paymentResult.isCancelled) return;
      if (!paymentResult.isSuccess) {
        errorMessage.value = paymentResult.message ?? AppLocalization.tr.paymentFailedMessage;
        return;
      }

      // The webhook usually lands within a second or two; wait briefly so the
      // wallet screen shows the new balance when we return to it.
      await _waitForBalanceAbove(accessToken, balanceBefore);

      AppSnackbar.snackbar(
        AppLocalization.tr.successTitle,
        AppLocalization.tr.depositCompletedMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate back with success result
      Get.back(result: true);
    } catch (e) {
      debugPrint('wallet_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.snackbar(
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

  Future<num?> _fetchBalance(String accessToken) async {
    final response = await _apiClient.getRequest(
      ApiUrls.getBalance,
      accessToken: accessToken,
    );
    if (!response.isSuccess) return null;
    return response.responseData['data']?['balance'] as num?;
  }

  Future<void> _waitForBalanceAbove(String accessToken, num? before) async {
    if (before == null) return;
    for (var attempt = 0; attempt < 6; attempt++) {
      await Future.delayed(const Duration(seconds: 1));
      final current = await _fetchBalance(accessToken);
      if (current != null && current > before) return;
    }
  }

  // ==================== Validation ====================
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.amountRequiredError;
    }
    final amount = parseAmount(value);
    if (amount == null || amount <= 0) {
      return AppLocalization.tr.invalidAmountError;
    }
    if (amount < minimumDeposit) {
      return AppLocalization.tr.depositMinimumError(formatPrice(minimumDeposit, decimals: 0));
    }
    if (amount > maximumDeposit) {
      return AppLocalization.tr.depositMaximumError(formatPrice(maximumDeposit, decimals: 0));
    }
    return null;
  }

  // ==================== Fetch Transactions ====================
  /// Page 1 replaces the list (first load, refresh); later pages append.
  Future<void> getTransactions({int page = 1, int limit = 10}) async {
    final isFirstPage = page == 1;
    if (!isFirstPage && isLoadingMoreTransactions.value) return;

    try {
      if (isFirstPage) {
        isLoading.value = true;
      } else {
        isLoadingMoreTransactions.value = true;
      }
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken() ?? '';
      currentUserId.value = prefs.getString('userId') ?? '';

      if (accessToken.isEmpty) {
        final msg = AppLocalization.tr.sessionExpiredMessage;
        errorMessage.value = msg;
        AppSnackbar.snackbar(
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

      if (isFirstPage) {
        transactions.assignAll(result.results);
      } else {
        transactions.addAll(result.results);
      }
      _transactionsPage = page;
      hasMoreTransactions.value = page < result.totalPages;

      logger.i('✅ Transactions fetched: ${result.results.length} (page $page of ${result.totalPages})');
    } catch (e) {
      final msg = e.toString();
      errorMessage.value = msg;

      logger.e(e);

      AppSnackbar.snackbar(
        AppLocalization.tr.errorTitle,
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMoreTransactions.value = false;
    }
  }

  Future<void> loadMoreTransactions() => getTransactions(page: _transactionsPage + 1);

  Future<void> getBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken() ?? '';

      if (accessToken.isEmpty) return;

      final response = await _apiClient.getRequest(
        ApiUrls.getBalance, // {{base-url}}/users/balance
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        balance.value = (response.responseData['data']['balance'] as num? ?? 0).toDouble();
      } else {
        AppSnackbar.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      AppSnackbar.snackbar(
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
      final accessToken = await SessionController.to.accessToken() ?? '';

      if (accessToken.isEmpty) {
        errorMessage.value = AppLocalization.tr.sessionExpiredMessage;
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
        AppSnackbar.snackbar(
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
      AppSnackbar.snackbar(
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
