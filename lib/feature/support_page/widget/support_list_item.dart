import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import '../data/support_message_model.dart';

class SupportListItem extends StatelessWidget {
  final SupportMessageModel supportMessage;
  final VoidCallback? onTap;

  const SupportListItem({
    super.key,
    required this.supportMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    supportMessage.subject,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                _buildStatusChip(supportMessage.status),
              ],
            ),
            SizedBox(height: 8.h),
            // Message
            Text(
              supportMessage.message,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            // Date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14.sp,
                  color: const Color(0xFF999999),
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(context, supportMessage.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'OPEN':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        break;
      case 'IN_PROGRESS':
        backgroundColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        break;
      case 'RESOLVED':
      case 'CLOSED':
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        break;
      default:
        backgroundColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF757575);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return AppLocalization.tr.supportStatusOpen;
      case 'IN_PROGRESS':
        return AppLocalization.tr.supportStatusInProgress;
      case 'RESOLVED':
        return AppLocalization.tr.supportStatusResolved;
      case 'CLOSED':
        return AppLocalization.tr.supportStatusClosed;
      default:
        return status;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return '${DateFormat.yMMMd(locale).format(date)} • ${DateFormat.jm(locale).format(date)}';
  }
}
