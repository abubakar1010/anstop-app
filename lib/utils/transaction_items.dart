import 'package:flutter/material.dart';
import '../app/utils/app_colors.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';


class TransactionItem extends StatelessWidget {
  final String title;
  final String time;
  final String amount;
  final bool isPositive;

  const TransactionItem({
    Key? key,
    required this.title,
    required this.time,
    required this.amount,
    required this.isPositive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
      border: Border.all(
        color: AppColors.grayShade100
      )
      //  borderRadius: BorderRadius.circular(12),

      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.greenIconBackground
                  : AppColors.redIconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isPositive
                  ? AppColors.successGreen
                  : AppColors.iconRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '' : '-'}${formatPrice(amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? AppColors.positiveAmount
                  : AppColors.negativeAmount,
            ),
          ),
        ],
      ),
    );
  }
}
