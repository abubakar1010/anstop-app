import 'package:get/get.dart';
import 'socket_services.dart';

/// Typed ride intents and independent event streams over one Socket.IO session.
class RealtimeClient extends GetxService {
  static RealtimeClient get to => Get.find<RealtimeClient>();
  SocketIoService get _socket => SocketIoService.to;

  Stream<Map<String, dynamic>> events(String name) => _socket.events
      .where((event) => event.name == name && event.data is Map)
      .map((event) => Map<String, dynamic>.from(event.data as Map));

  Future<RealtimeAck> acceptRide(String rideId, String driverId) =>
      _socket.request('accept-ride', {'rideId': rideId, 'driverId': driverId});
  Future<RealtimeAck> offerRide(String rideId) =>
      _socket.request('new-offer', {'rideId': rideId});
  Future<RealtimeAck> pickupRider() => _socket.request('pickup-rider', {});
  Future<RealtimeAck> completeRide() => _socket.request('drop-off-rider', {});
  Future<RealtimeAck> cancelRide(String rideId, String reason) =>
      _socket.request('cancel-ride', {'rideId': rideId, 'reason': reason});
}
