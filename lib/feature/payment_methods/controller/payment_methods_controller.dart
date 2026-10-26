import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/payment_methods/data/saved_card.dart';
import 'package:ride_sharing/feature/payment_methods/service/payment_methods_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/stripe/stripe_config.dart';
import 'package:ride_sharing/services/stripe/stripe_helper.dart';

class PaymentMethodsController extends GetxController {
  final PaymentMethodsService _service = PaymentMethodsService();
  final StripePaymentHelper _stripeHelper = StripePaymentHelper(
    config: const StripeConfig(merchantDisplayName: 'Anstop'),
    onLog: (message) => debugPrint('[Stripe] $message'),
  );

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;
  final RxList<SavedCard> cards = <SavedCard>[].obs;
  final RxString errorMessage = ''.obs;

  /// The card a set-default or remove request is running for.
  final RxString busyId = ''.obs;

  SavedCard? get defaultCard => cards.firstWhereOrNull((c) => c.isDefault);

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadCards();
  }

  // ==================== Business Logic ====================
  Future<void> loadCards() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _service.listCards();
      if (!response.isSuccess) {
        errorMessage.value = response.errorMessage;
        return;
      }
      cards.assignAll(SavedCard.listFromJson(response.responseData['data']));
    } catch (e) {
      debugPrint('payment_methods_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens Stripe's card sheet; the card goes straight to Stripe, never
  /// through our server.
  Future<void> addCard(BuildContext context) async {
    if (isAdding.value) return;
    try {
      isAdding.value = true;
      final response = await _service.createSetupIntent();
      final data = response.isSuccess ? response.responseData['data'] : null;
      final secret = data?['setupIntentClientSecret'] as String?;
      final customerId = data?['customerId'] as String?;
      final ephemeralKey = data?['ephemeralKey'] as String?;
      if (secret == null || customerId == null || ephemeralKey == null) {
        AppSnackbar.error(
          AppLocalization.tr.errorTitle,
          response.isSuccess ? AppLocalization.tr.genericErrorMessage : response.errorMessage,
        );
        return;
      }
      if (!context.mounted) return;

      final countBefore = cards.length;
      final result = await _stripeHelper.saveCard(
        context: context,
        setupIntentClientSecret: secret,
        customerId: customerId,
        ephemeralKey: ephemeralKey,
      );
      if (!result.isSuccess) return;

      AppSnackbar.success(AppLocalization.tr.successTitle, AppLocalization.tr.cardAddedMessage);
      await loadCards();
      // Stripe can take a moment to list a card it has just saved.
      if (cards.length <= countBefore) {
        await Future.delayed(const Duration(milliseconds: 1500));
        await loadCards();
      }
    } catch (e) {
      debugPrint('payment_methods_controller: $e');
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> setDefault(SavedCard card) async {
    if (card.isDefault || busyId.isNotEmpty) return;
    await _update(card, () => _service.setDefault(card.id),
        AppLocalization.tr.defaultCardUpdatedMessage);
  }

  Future<void> remove(SavedCard card) async {
    if (busyId.isNotEmpty) return;
    await _update(card, () => _service.removeCard(card.id),
        AppLocalization.tr.cardRemovedMessage);
  }

  /// Both endpoints answer with the updated card list.
  Future<void> _update(
    SavedCard card,
    Future<ApiResponse> Function() request,
    String successMessage,
  ) async {
    try {
      busyId.value = card.id;
      final response = await request();
      if (!response.isSuccess) {
        AppSnackbar.error(AppLocalization.tr.errorTitle, response.errorMessage);
        return;
      }
      cards.assignAll(SavedCard.listFromJson(response.responseData['data']));
      AppSnackbar.success(AppLocalization.tr.successTitle, successMessage);
    } catch (e) {
      debugPrint('payment_methods_controller: $e');
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      busyId.value = '';
    }
  }
}
