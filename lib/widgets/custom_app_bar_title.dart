import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/passenger/passenger_custom_drawer.dart';
import 'logo.dart';
import 'unread_badge.dart';

class CustomAppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey; // 👈 now optional
  final String? title;
  final bool centerTitle;
  final Color? titleColor;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;

  @override
  final Size preferredSize;

  const CustomAppBarTitle({
    super.key,
    this.scaffoldKey, // optional key
    this.title,
    this.centerTitle = true,
    this.titleColor,
    this.titleFontSize,
    this.titleFontWeight,
    this.preferredSize = const Size.fromHeight(80),
  });

  @override
  Widget build(BuildContext context) {
    // Default text style from theme, then override as needed
    final baseStyle = Theme.of(context).textTheme.titleLarge;

    TextStyle? effectiveStyle;
    if (baseStyle != null) {
      effectiveStyle = baseStyle.copyWith(
        color: titleColor ?? baseStyle.color ?? Colors.black,
        fontSize: titleFontSize ?? baseStyle.fontSize,
        fontWeight: titleFontWeight ?? baseStyle.fontWeight ?? FontWeight.bold,
      );
    } else {
      // Fallback if titleLarge is null (unlikely, but safe)
      effectiveStyle = TextStyle(
        color: titleColor ?? Colors.black,
        fontSize: titleFontSize ?? 20.sp,
        fontWeight: titleFontWeight ?? FontWeight.bold,
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: centerTitle,
      leading: IconButton(
        // The badge tells the user there is something new behind the menu.
        icon: const WithUnreadBadge(child: Icon(Icons.menu, color: Colors.black)),
        onPressed: scaffoldKey != null
            ? () => scaffoldKey!.currentState?.openDrawer()
            : () => Scaffold.of(context).openDrawer(), // fallback to context
      ),
      title: title != null && title!.isNotEmpty
          ? Text(title!, style: effectiveStyle)
          : null,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.0.w, top: 8.h), // 👈 responsive padding
          child: IconWidget(
            width: 40.w,
            height: 40.h,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }
}
