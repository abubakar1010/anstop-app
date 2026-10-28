import 'package:ride_sharing/utils/drawer_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_sharing/feature/notification/model/notification_model.dart';
import 'package:ride_sharing/feature/notification/utils/notification_date_header.dart';
import 'package:ride_sharing/feature/notification/utils/notification_item.dart';
import '../../../app/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/notification/controller/notification_controller.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNavigation.openedFromDrawer(context) ? const ModeDrawer() : null,
      backgroundColor: NotificationColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const DrawerOrBackButton(color: NotificationColors.menuIconColor),
        title: Text(
          AppLocalization.tr.notificationTitle,
          style: const TextStyle(
            color: NotificationColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.hasUnread
              ? IconButton(
                  tooltip: AppLocalization.tr.markAllAsReadButton,
                  icon: const Icon(Icons.done_all, color: NotificationColors.menuIconColor),
                  onPressed: controller.markAllAsRead,
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.notifications.isEmpty) {
          return _CenteredMessage(
            icon: Icons.wifi_off_rounded,
            title: controller.errorMessage.value,
            action: TextButton(
              onPressed: controller.loadNotifications,
              child: Text(AppLocalization.tr.retryButton),
            ),
          );
        }
        final groups = controller.groups;
        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: groups.isEmpty
              // Scrollable so pull-to-refresh still works on the empty state.
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    _CenteredMessage(
                      icon: Icons.notifications_none_rounded,
                      title: AppLocalization.tr.noNotificationsTitle,
                      message: AppLocalization.tr.noNotificationsMessage,
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: groups.length,
                  itemBuilder: (context, groupIndex) {
                    final group = groups[groupIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NotificationDateHeader(dateLabel: group.dateLabel),
                        for (final notification in group.notifications)
                          NotificationItem(
                            notification: notification,
                            onTap: () {
                              controller.markAsRead(notification);
                              _showNotificationDetails(notification);
                            },
                          ),
                      ],
                    );
                  },
                ),
        );
      }),
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

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

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
                color: NotificationColors.iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: NotificationColors.iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NotificationColors.titleText,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: NotificationColors.secondaryText,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 8), action!],
          ],
        ),
      ),
    );
  }
}
