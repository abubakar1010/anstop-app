import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_sharing/feature/notification/model/notification_model.dart';
import 'package:ride_sharing/feature/notification/utils/notification_date_header.dart';
import 'package:ride_sharing/feature/notification/utils/notification_item.dart';
import '../../../app/utils/app_colors.dart';
import '../../../l10n/l10n_helper.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationGroup> notificationGroups;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    notificationGroups = [
      NotificationGroup(
        dateLabel: AppLocalization.tr.todayLabel,
        notifications: [
          NotificationModel(
            title: AppLocalization.tr.notificationPaymentSuccess,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.payment,
            dateTime: DateTime.now(),
          ),
          NotificationModel(
            title: AppLocalization.tr.notificationSpecialDiscount30,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.discount,
            dateTime: DateTime.now(),
          ),
        ],
      ),
      NotificationGroup(
        dateLabel: AppLocalization.tr.yesterdayLabel,
        notifications: [
          NotificationModel(
            title: AppLocalization.tr.notificationPaymentSuccess,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.payment,
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
          NotificationModel(
            title: AppLocalization.tr.notificationCreditCardAdded,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.creditCard,
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
          NotificationModel(
            title: AppLocalization.tr.notificationWalletAddedSuccess,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.wallet,
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
          NotificationModel(
            title: AppLocalization.tr.notificationSpecialDiscount5,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.discount,
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      NotificationGroup(
        dateLabel: 'May, 27 2023',
        notifications: [
          NotificationModel(
            title: AppLocalization.tr.notificationPaymentSuccess,
            description: AppLocalization.tr.notificationDescription,
            type: NotificationType.payment,
            dateTime: DateTime(2023, 5, 27),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: NotificationColors.menuIconColor,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalization.tr.notificationTitle,
          style: const TextStyle(
            color: NotificationColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: notificationGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = notificationGroups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationDateHeader(dateLabel: group.dateLabel),
                    ...group.notifications.map((notification) {
                      return NotificationItem(
                        notification: notification,
                        onTap: () {
                          // Handle notification tap
                          _showNotificationDetails(notification);
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          // Bottom Indicator
          Container(
            width: 134,
            height: 5,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: NotificationColors.bottomIndicator,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: NotificationColors.iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification.icon,
                      color: NotificationColors.iconColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NotificationColors.titleText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notification.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: NotificationColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NotificationColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    AppLocalization.tr.closeButton,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
