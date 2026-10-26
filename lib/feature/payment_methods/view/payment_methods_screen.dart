import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/feature/payment_methods/controller/payment_methods_controller.dart';
import 'package:ride_sharing/feature/payment_methods/data/saved_card.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentMethodsController>();
    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.appBarTitleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.tr.paymentMethodsTitle,
          style: const TextStyle(
            color: AppColors.appBarTitleColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.cards.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty && controller.cards.isEmpty) {
          return _CenteredMessage(
            icon: Icons.wifi_off_rounded,
            title: controller.errorMessage.value,
            action: TextButton(
              onPressed: controller.loadCards,
              child: Text(AppLocalization.tr.retryButton),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadCards,
          child: ListView(
            // Scrollable even when short so pull-to-refresh always works.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (controller.cards.isEmpty) ...[
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
                _CenteredMessage(
                  icon: Icons.credit_card_rounded,
                  title: AppLocalization.tr.noSavedCardsTitle,
                  message: AppLocalization.tr.noSavedCardsMessage,
                ),
              ] else ...[
                for (final card in controller.cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SavedCardTile(
                      card: card,
                      isBusy: controller.busyId.value == card.id,
                      onTap: () => _showCardActions(context, controller, card),
                    ),
                  ),
                const SizedBox(height: 4),
                _InfoNote(
                  icon: Icons.bolt_rounded,
                  text: AppLocalization.tr.defaultCardHint,
                ),
              ],
              const SizedBox(height: 12),
              _InfoNote(
                icon: Icons.lock_outline_rounded,
                text: AppLocalization.tr.cardsSecureNote,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Obx(
          () => SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: controller.isAdding.value ? null : () => controller.addCard(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: controller.isAdding.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_card_rounded),
              label: Text(
                AppLocalization.tr.addCardButton,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCardActions(BuildContext context, PaymentMethodsController controller, SavedCard card) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    _BrandBadge(card: card),
                    const SizedBox(width: 12),
                    Text(
                      '${card.brandName} ${card.maskedNumber}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (!card.isDefault)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: AppColors.primaryColor),
                  title: Text(AppLocalization.tr.setAsDefaultAction),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.setDefault(card);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: Text(
                  AppLocalization.tr.removeCardAction,
                  style: const TextStyle(color: AppColors.red),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmRemove(context, controller, card);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, PaymentMethodsController controller, SavedCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalization.tr.removeCardTitle),
        content: Text(AppLocalization.tr.removeCardMessage('${card.brandName} ${card.maskedNumber}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalization.tr.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              AppLocalization.tr.removeCardAction,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.remove(card);
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({required this.card, required this.isBusy, required this.onTap});

  final SavedCard card;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final expired = card.isExpired();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isBusy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: card.isDefault ? AppColors.primaryColor : AppColors.borderColor,
              width: card.isDefault ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _BrandBadge(card: card),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${card.brandName} ${card.maskedNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appBarTitleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expired
                          ? AppLocalization.tr.cardExpiredLabel
                          : AppLocalization.tr.cardExpiresLabel(card.expiry),
                      style: TextStyle(
                        fontSize: 13,
                        color: expired ? AppColors.red : AppColors.appGreyColor,
                        fontWeight: expired ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (card.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.greenShade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalization.tr.defaultCardLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              else
                const Icon(Icons.more_vert, color: AppColors.appGreyColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.card});

  final SavedCard card;

  static const _labels = {
    'visa': 'VISA',
    'mastercard': 'MC',
    'amex': 'AMEX',
    'cartes_bancaires': 'CB',
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[card.brand];
    return Container(
      width: 48,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: card.brandColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: label == null
          ? const Icon(Icons.credit_card, color: Colors.white, size: 20)
          : Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.appGreyColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.appGreyColor, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.greenShade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.appBarTitleColor,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.appGreyColor, height: 1.4),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}
