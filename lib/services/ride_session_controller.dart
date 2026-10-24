import 'dart:async';
import 'package:get/get.dart';
import 'api_client.dart';
import 'api_urls.dart';
import 'realtime_client.dart';
import 'session_controller.dart';
import 'socket_services.dart';

class RideSnapshot {
  final String rideId;
  final String status;
  final String riderId;
  final String? driverId;
  final DateTime? expiresAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> data;

  RideSnapshot(this.data)
      : rideId = (data['rideId'] ?? data['_id']).toString(),
        status = data['status']?.toString() ?? '',
        riderId = data['riderId']?.toString() ?? '',
        driverId = data['driverId']?.toString(),
        expiresAt = DateTime.tryParse(data['expiresAt']?.toString() ?? ''),
        updatedAt = DateTime.tryParse(data['updatedAt']?.toString() ?? '');

  bool get isActive => status == 'PENDING' || status == 'ACCEPTED' ||
      status == 'ONGOING' || (status == 'COMPLETED' && data['isPaymentCompleted'] != true);
}

/// One ride snapshot shared by driver and passenger screens; reconnect refetches it.
class RideSessionController extends GetxService {
  static RideSessionController get to => Get.find<RideSessionController>();
  final Rxn<RideSnapshot> ride = Rxn<RideSnapshot>();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Worker? _connectionWorker;
  int _version = 0;

  RideSessionController initialize() {
    _subscription = RealtimeClient.to.events('ride:state').listen(applySnapshot);
    _connectionWorker = ever<bool>(SocketIoService.to.isConnected, (connected) {
      if (connected) loadCurrent();
    });
    if (SocketIoService.to.isConnected.value) loadCurrent();
    return this;
  }

  void applySnapshot(Map<String, dynamic> data) {
    final next = RideSnapshot(data);
    final current = ride.value;
    if (current?.rideId == next.rideId && current?.updatedAt != null &&
        next.updatedAt != null && next.updatedAt!.isBefore(current!.updatedAt!)) {
      return;
    }
    ride.value = next;
    _version++;
  }

  Future<void> loadCurrent() async {
    if (SessionController.to.accountState.value != 'ACTIVE') return;
    final startedAtVersion = _version;
    final response = await ApiClient().getRequest(ApiUrls.currentRide);
    if (!response.isSuccess) return;
    if (_version != startedAtVersion) return;
    final data = response.responseData is Map ? response.responseData['data'] : null;
    if (data is Map) {
      applySnapshot(Map<String, dynamic>.from(data));
    } else {
      ride.value = null;
      _version++;
    }
  }

  Future<RealtimeAck> acceptRide(String rideId, String driverId) async {
    final ack = await RealtimeClient.to.acceptRide(rideId, driverId);
    _applyAck(ack);
    return ack;
  }
  Future<RealtimeAck> pickupRider() async {
    final ack = await RealtimeClient.to.pickupRider();
    _applyAck(ack);
    return ack;
  }
  Future<RealtimeAck> completeRide() async {
    final ack = await RealtimeClient.to.completeRide();
    _applyAck(ack);
    return ack;
  }
  Future<RealtimeAck> cancelRide(String rideId, String reason) async {
    final ack = await RealtimeClient.to.cancelRide(rideId, reason);
    _applyAck(ack);
    return ack;
  }
  void _applyAck(RealtimeAck ack) {
    if (ack.ok && ack.data is Map) applySnapshot(Map<String, dynamic>.from(ack.data as Map));
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _connectionWorker?.dispose();
    super.onClose();
  }
}
