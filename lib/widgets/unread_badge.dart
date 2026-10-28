import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/services/notification_badge_service.dart';

/// The red unread-notifications count, hidden when there is nothing unread.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationBadgeService>()) return const SizedBox.shrink();
    return Obx(() {
      final count = NotificationBadgeService.to.unreadCount.value;
      if (count <= 0) return const SizedBox.shrink();
      // Sized by its own text, never by the space around it: inside a
      // ListTile's trailing slot an aligned box would take the whole row.
      return Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18, maxHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Center(
          widthFactor: 1,
          child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          ),
        ),
      );
    });
  }
}

/// [child] with the unread badge on its top-right corner.
class WithUnreadBadge extends StatelessWidget {
  const WithUnreadBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const Positioned(top: -6, right: -8, child: UnreadBadge()),
      ],
    );
  }
}
