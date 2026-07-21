import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuShowHelper {
  static final List<String> heightOptions = List.generate(100, (index) {
    return "${(index ~/ 12) + 4}'${(index % 12)}\" cm";
  });

  static final List<String> weightOptions = List.generate(66, (index) {
    return "${35 + index} kg";
  });

  static final List<String> subjects = [
    "French",
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "English",
    "Computer Science",
  ];
  /// Shows a popup menu at the tap position from TapDownDetails.
  /// Returns the selected value or null if none selected.
  static Future<String?> showCustomMenu({
    required BuildContext context,
    required TapDownDetails details,
    required List<String> options,
  }) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset tapPosition = details.globalPosition;

    return showMenu<String>(
      context: context,
      color: Colors.white,
      constraints: BoxConstraints(
        maxHeight: 200.h,
        minWidth: 120.w,
        maxWidth: 180.w,
      ),
      position: RelativeRect.fromRect(
        Rect.fromPoints(tapPosition, tapPosition),
        Offset.zero & overlay.size,
      ),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
          child: SizedBox(
            height: 28.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option,
                style: TextStyle(fontSize: 12.sp, color: Colors.black),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
