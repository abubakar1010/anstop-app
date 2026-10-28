import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing/feature/notification/model/notification_model.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';
import 'package:ride_sharing/services/notification_badge_service.dart';
import 'package:ride_sharing/services/realtime_client.dart';

class NotificationController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<Map<String, dynamic>>? _liveSubscription;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    // A notification created while this screen is open appears at the top.
    _liveSubscription = RealtimeClient.to.events('notification:updated').listen((data) {
      final item = data['notification'];
      if (item is! Map) return;
      final notification = NotificationModel.fromJson(Map<String, dynamic>.from(item));
      if (notifications.any((n) => n.id == notification.id)) return;
      notifications.insert(0, notification);
    });
  }

  @override
  void onClose() {
    _liveSubscription?.cancel();
    super.onClose();
  }

  // ==================== Business Logic ====================
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _apiClient.getRequest(
        ApiUrls.notifications,
        queryParams: {'limit': 50, 'sortBy': 'createdAt', 'sortOrder': 'desc'},
      );
      if (!response.isSuccess) {
        errorMessage.value = response.errorMessage;
        return;
      }
      final data = response.responseData['data'];
      notifications.assignAll([
        if (data is List)
          for (final item in data)
            if (item is Map)
              NotificationModel.fromJson(Map<String, dynamic>.from(item)),
      ]);
      // The list shows the newest 50 only; the badge needs the real total.
      NotificationBadgeService.to.refreshCount();
    } catch (e) {
      debugPrint('notification_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasUnread => notifications.any((n) => !n.isRead);

  /// Marks one notification read as soon as it is opened. The list updates
  /// at once; the badge takes the server's count.
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    _setRead((n) => n.id == notification.id, true);
    final response = await _apiClient.patchRequest(ApiUrls.notificationRead(notification.id));
    if (response.isSuccess) {
      _applyUnreadCount(response);
    } else {
      debugPrint('notification_controller: ${response.errorMessage}');
      _setRead((n) => n.id == notification.id, false);
    }
  }

  Future<void> markAllAsRead() async {
    final previouslyUnread = {for (final n in notifications) if (!n.isRead) n.id};
    if (previouslyUnread.isEmpty) return;
    _setRead((_) => true, true);
    NotificationBadgeService.to.unreadCount.value = 0;
    final response = await _apiClient.patchRequest(ApiUrls.notificationsReadAll);
    if (!response.isSuccess) {
      debugPrint('notification_controller: ${response.errorMessage}');
      _setRead((n) => previouslyUnread.contains(n.id), false);
      await NotificationBadgeService.to.refreshCount();
    }
  }

  void _setRead(bool Function(NotificationModel) which, bool isRead) {
    notifications.assignAll([
      for (final n in notifications) which(n) ? n.copyWith(isRead: isRead) : n,
    ]);
  }

  void _applyUnreadCount(ApiResponse response) {
    final data = response.responseData is Map ? response.responseData['data'] : null;
    final count = data is Map ? data['unreadCount'] : null;
    if (count is num) NotificationBadgeService.to.unreadCount.value = count.toInt();
  }

  /// Notifications grouped under "Today", "Yesterday" or their date, newest first.
  List<NotificationGroup> get groups {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final grouped = <DateTime, List<NotificationModel>>{};
    for (final notification in notifications) {
      final d = notification.dateTime;
      grouped.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(notification);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final day in days)
        NotificationGroup(
          dateLabel: day == today
              ? AppLocalization.tr.todayLabel
              : day == today.subtract(const Duration(days: 1))
              ? AppLocalization.tr.yesterdayLabel
              : DateFormat.yMMMd().format(day),
          notifications: grouped[day]!,
        ),
    ];
  }
}
