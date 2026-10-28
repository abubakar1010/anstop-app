import 'dart:async';
import 'package:get/get.dart';
import 'api_client.dart';
import 'api_urls.dart';
import 'realtime_client.dart';
import 'session_controller.dart';
import 'socket_services.dart';

/// The unread-notification count shown on the menu button and in the drawer.
///
/// The server pushes the new count on "notification:updated" whenever a
/// notification is created or read; reconnecting refetches it, since events
/// sent while offline are lost.
class NotificationBadgeService extends GetxService {
  static NotificationBadgeService get to => Get.find<NotificationBadgeService>();

  final RxInt unreadCount = 0.obs;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Worker? _connectionWorker;
  Worker? _sessionWorker;

  NotificationBadgeService initialize() {
    _subscription = RealtimeClient.to.events('notification:updated').listen((data) {
      final count = data['unreadCount'];
      if (count is num) unreadCount.value = count.toInt();
    });
    _connectionWorker = ever<bool>(SocketIoService.to.isConnected, (connected) {
      if (connected) refreshCount();
    });
    // Signing out must not leave the previous user's count on screen.
    _sessionWorker = ever<String?>(SessionController.to.accountState, (state) {
      if (state == null) unreadCount.value = 0;
    });
    if (SocketIoService.to.isConnected.value) refreshCount();
    return this;
  }

  Future<void> refreshCount() async {
    if (SessionController.to.accountState.value != 'ACTIVE') return;
    final response = await ApiClient().getRequest(ApiUrls.notificationsUnreadCount);
    if (!response.isSuccess) return;
    final data = response.responseData is Map ? response.responseData['data'] : null;
    final count = data is Map ? data['unreadCount'] : null;
    if (count is num) unreadCount.value = count.toInt();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _connectionWorker?.dispose();
    _sessionWorker?.dispose();
    super.onClose();
  }
}
