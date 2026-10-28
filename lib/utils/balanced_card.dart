import 'package:flutter/material.dart';

import '../app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';


class BalanceCard extends StatelessWidget {
  final String balance;
  final VoidCallback? onWithdraw;
  final VoidCallback? onDeposit;
  final bool showWithdraw;

  const BalanceCard({
    Key? key,
    required this.balance,
    this.onWithdraw,
    this.onDeposit,
    this.showWithdraw = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D4D3D),
            Color(0xFF1A5F4A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalization.tr.availableBalanceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                // Large balances shrink to fit instead of pushing the buttons off the card.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatPrice(balance),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              if (showWithdraw && onWithdraw != null)
                _buildActionButton(AppLocalization.tr.withdrawNowButton, onWithdraw!),
              if (showWithdraw && onWithdraw != null)
                const SizedBox(height: 8),
              if (onDeposit != null)
                _buildActionButton(AppLocalization.tr.depositButton, onDeposit!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenShade300,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(120, 36),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
