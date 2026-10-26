import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

class TripIdWidget extends StatelessWidget {
  const TripIdWidget({super.key, required this.tripId});

  /// The ride's id from the server.
  final String tripId;

  /// Short, readable form of the id; the copy button copies the full one.
  String get _displayId {
    final short = tripId.length > 6 ? tripId.substring(tripId.length - 6) : tripId;
    return '#${short.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    if (tripId.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalization.tr.tripIdLabel,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text(
                _displayId,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: tripId));
              AppSnackbar.show(
                title: AppLocalization.tr.tripIdLabel,
                message: AppLocalization.tr.tripIdCopiedMessage,
              );
            },
            icon: Icon(Icons.copy, color: AppColors.appGreyColor),
          ),
        ],
      ),
    );
  }
}
