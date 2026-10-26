import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing/feature/notification/model/notification_model.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/services/api_client.dart';
import 'package:ride_sharing/services/api_urls.dart';

class NotificationController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxString errorMessage = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
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
    } catch (e) {
      debugPrint('notification_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
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
