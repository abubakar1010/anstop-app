import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class RideNeedsDropdown extends StatefulWidget {
  final Function(List<String>) onSelectionChanged;

  const RideNeedsDropdown({
    Key? key,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _RideNeedsDropdownState createState() => _RideNeedsDropdownState();
}

class _RideNeedsDropdownState extends State<RideNeedsDropdown> {
  bool _isExpanded = false;
  final List<String> _selectedItems = [];

  Map<String, String> get _rideNeedsOptions => {
        'WHEELCHAIR_ACCESSIBLE': AppLocalization.tr.rideNeedWheelchair,
        'EXTRA_LUGGAGE_SPACE': AppLocalization.tr.rideNeedExtraLuggage,
        'PET_FRIENDLY': AppLocalization.tr.rideNeedPetFriendly,
        'CHILD_SEAT': AppLocalization.tr.rideNeedChildSeat,
      };

  void _toggleItem(String value) {
    setState(() {
      if (_selectedItems.contains(value)) {
        _selectedItems.remove(value);
      } else {
        _selectedItems.add(value);
      }
      widget.onSelectionChanged(_selectedItems);
    });
  }

  String _getDisplayText() {
    if (_selectedItems.isEmpty) {
      return AppLocalization.tr.selectRideNeedsHint;
    }
    return _selectedItems.map((e) => _rideNeedsOptions[e]).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grayShade100),
              borderRadius: BorderRadius.circular(10.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 14.sp),
            child: Row(
              children: [
                Icon(
                  Icons.accessibility_new,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _selectedItems.isEmpty
                          ? AppColors.appGreyColor
                          : AppColors.darkColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grayShade100),
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.white,
            ),
            child: Column(
              children: _rideNeedsOptions.entries.map((entry) {
                final isSelected = _selectedItems.contains(entry.key);
                return InkWell(
                  onTap: () => _toggleItem(entry.key),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.sp,
                      vertical: 12.sp,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.grayShade100.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.appGreyColor,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.darkColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
