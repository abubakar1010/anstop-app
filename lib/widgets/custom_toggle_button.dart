import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class ToggleButtonsWidget extends StatelessWidget {
  final bool isOngoing;
  final ValueChanged<bool> onToggleChanged;

  const ToggleButtonsWidget({
    Key? key,
    required this.isOngoing,
    required this.onToggleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: Row(
        children: [
          _toggleButton(
            AppLocalization.tr.ongoingStatus,
            isSelected: isOngoing,
            onTap: () => onToggleChanged(true),
          ),
          _toggleButton(
            AppLocalization.tr.completedStatus,
            isSelected: !isOngoing,
            onTap: () => onToggleChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, {required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.togglebuttonColor : AppColors.secondaryBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
