import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_urls.dart';
import 'locale_service.dart';
import 'session_controller.dart';

class RealtimeEvent {
  final String name;
  final dynamic data;
  const RealtimeEvent(this.name, this.data);
}

class RealtimeAck {
  final bool ok;
  final String code;
  final dynamic data;
  const RealtimeAck(this.ok, this.code, [this.data]);
}

class SocketIoService extends GetxService {
  final Logger _logger = Logger();
  IO.Socket? _socket;
  final RxBool isConnected = false.obs;
  final StreamController<RealtimeEvent> _events = StreamController<RealtimeEvent>.broadcast();
  Stream<RealtimeEvent> get events => _events.stream;

  // Buffer for incompleted-ride — server sends it at the instant of connection,
  // before any listener can be registered. Store it here and replay on registration.
  dynamic _incompletedRideBuffer;
  Function(dynamic)? _incompletedRideHandler;

  static SocketIoService get to => Get.find<SocketIoService>();

  Future<SocketIoService> init() async {
    return this;
  }

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      _logger.i('Socket already connected');
      return;
    }

    if (SessionController.to.accountState.value != 'ACTIVE') return;
    final token = await SessionController.to.accessToken() ?? '';

    if (token.isEmpty) {
      _logger.e('No access token found for socket connection');
      return;
    }

    _logger.i('Creating socket connection to ${ApiUrls.socketUrl}');

    final completer = Completer<void>();

    _incompletedRideBuffer = null;
    _socket?.dispose();

    _socket = IO.io(ApiUrls.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      // A function, so every reconnect sends the language active at that
      // moment rather than the one at first connect.
      'auth': (void Function(Map<String, dynamic>) send) =>
          send({'token': token, 'lang': LocaleService.languageCode}),
    });

    // Register early — server sends incompleted-ride at the moment of connection,
    // before onConnect fires. Buffer it and forward to any registered handler.
    _socket!.on('incompleted-ride', (data) {
      _logger.i('incompleted-ride buffered on connect: $data');
      _incompletedRideBuffer = data;
      _incompletedRideHandler?.call(data);
    });

    _socket!.onConnect((_) {
      _logger.i('Socket connected successfully!');
      isConnected.value = true;
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    _socket!.onDisconnect((_) {
      _logger.w('Socket disconnected');
      isConnected.value = false;
      _incompletedRideBuffer = null;
    });

    _socket!.onConnectError((data) {
      _logger.e('Socket connection error — type: ${data.runtimeType}');
      _logger.e('Socket connection error — raw: $data');
      if (data is Map) {
        _logger.e('Socket connection error — message: ${data['message']}');
        _logger.e('Socket connection error — data field: ${data['data']}');
      }
      isConnected.value = false;
      if (!completer.isCompleted) {
        completer.complete();
      }
      final code = data is Map
          ? (data['data'] is Map ? data['data']['code'] : data['code'])
          : null;
      if (code is String) SessionController.to.updateFromErrorCode(code);
      if (code == 'TOKEN_EXPIRED') {
        SessionController.to.refresh().then((token) {
          if (token != null &&
              SessionController.to.accountState.value == 'ACTIVE')
            connect();
        });
      } else if (code != 'ONBOARDING_REQUIRED' &&
          code != 'ACCOUNT_PENDING_REVIEW' &&
          code != 'ACCOUNT_SUSPENDED' &&
          code != 'ACCOUNT_REJECTED' &&
          code != 'ACCOUNT_DELETED' &&
          code != 'TOKEN_INVALID' &&
          code != 'UNAUTHENTICATED') {
        _retryConnection();
      }
    });

    _socket!.onError((data) {
      _logger.e('Socket error — type: ${data.runtimeType}');
      _logger.e('Socket error — raw: $data');
    });

    _socket!.onAny((event, data) {
      _logger.i('Socket event received: $event, data: $data');
      _events.add(RealtimeEvent(event.toString(), data));
    });

    // Wait for connection with timeout
    try {
      await completer.future.timeout(const Duration(seconds: 10));
      _logger.i(
        'Socket connection completed, isConnected: ${isConnected.value}',
      );
    } catch (e) {
      _logger.e('Socket connection timeout: $e');
    }
  }

  void _retryConnection() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_socket != null &&
          !_socket!.connected &&
          SessionController.to.accountState.value == 'ACTIVE') {
        _logger.i('Retrying socket connection...');
        _socket!.connect();
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  void on(String event, Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register listener for $event - socket is null!');
      return;
    }
    _logger.i(
      'Registering listener for event: $event, socket connected: ${_socket!.connected}',
    );
    _socket!.on(event, handler);
  }

  /// Tells the server which language to write socket messages in from now on.
  /// Sent as an event so the current socket keeps its ride subscriptions.
  void setLanguage(String languageCode) {
    if (_socket?.connected ?? false) {
      request('set-language', {'lang': languageCode});
    }
  }

  Future<RealtimeAck> request(String event, Map<String, dynamic> payload) async {
    if (!isSocketReady) await connect();
    if (!isSocketReady) return const RealtimeAck(false, 'NOT_CONNECTED');
    final completer = Completer<RealtimeAck>();
    _socket!.emitWithAck(event, payload, ack: (dynamic raw) {
      if (completer.isCompleted) return;
      if (raw is Map) {
        completer.complete(RealtimeAck(raw['ok'] == true || raw['success'] == true,
            raw['code']?.toString() ?? 'UNKNOWN', raw['data']));
      } else {
        completer.complete(const RealtimeAck(false, 'INVALID_ACK'));
      }
    });
    return completer.future.timeout(const Duration(seconds: 10),
        onTimeout: () => const RealtimeAck(false, 'TIMEOUT'));
  }

  void off(String event) {
    _logger.i('Removing listener for event: $event');
    _socket?.off(event);
  }

  // Listen for nearest drivers
  void onNearestDrivers(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register nearest-drivers listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering nearest-drivers listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('nearest-drivers', (data) {
      _logger.i('nearest-drivers event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for nearest drivers
  void offNearestDrivers() {
    _logger.i('Removing nearest-drivers listener');
    _socket?.off('nearest-drivers');
  }

  // Listen for ride request (for drivers)
  void onRideRequest(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register ride-request listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering ride-request listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('ride-request', (data) {
      _logger.i('ride-request event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for ride request
  void offRideRequest() {
    _logger.i('Removing ride-request listener');
    _socket?.off('ride-request');
  }

  // Check if socket is ready
  bool get isSocketReady => _socket != null && _socket!.connected;

  // Send a new message
  Future<bool> sendMessage({
    required String conversationId,
    String? text,
    String? attachments,
  }) async {
    if (text == null && attachments == null) {
      _logger.e('At least one of text or attachments is required');
      return false;
    }

    final payload = <String, dynamic>{'conversationId': conversationId};

    if (text != null && text.isNotEmpty) {
      payload['text'] = text;
    }

    if (attachments != null && attachments.isNotEmpty) {
      payload['attachments'] = attachments;
    }

    _logger.i('Sending message: $payload');
    return (await request('send-new-message', payload)).ok;
  }

  // Listen for new messages
  void onNewMessage(Function(dynamic) handler) {
    on('new-message', handler);
  }

  // Stop listening for new messages
  void offNewMessage() {
    off('new-message');
  }

  // Listen for ride accepted (for drivers)
  void onRideAccepted(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register ride-accepted listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering ride-accepted listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('ride-accepted', (data) {
      _logger.i('ride-accepted event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for ride accepted
  void offRideAccepted() {
    _logger.i('Removing ride-accepted listener');
    _socket?.off('ride-accepted');
  }

  Future<bool> emitPickupRider() async => (await request('pickup-rider', {})).ok;

  Future<bool> emitDropOffRider() async => (await request('drop-off-rider', {})).ok;

  // Listen for update-location (for passengers - receives driver's real-time GPS position)
  void onUpdateLocation(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register update-location listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering update-location listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('update-location', (data) {
      _logger.i('update-location event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for update-location
  void offUpdateLocation() {
    _logger.i('Removing update-location listener');
    _socket?.off('update-location');
  }

  // Emit update-location (for drivers - continuously sends current GPS position)
  Future<bool> emitUpdateLocation({required String locationName, required double latitude,
      required double longitude}) async {
    final ack = await request('update-location', {
      'locationName': locationName, 'latitude': latitude, 'longitude': longitude,
    });
    return ack.ok;
  }

  Future<bool> emitNewOffer({required String rideId}) async =>
      (await request('new-offer', {'rideId': rideId})).ok;

  // Listen for new-offer (for passengers - driver sends a direct offer)
  void onNewOffer(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register new-offer listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering new-offer listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('new-offer', (data) {
      _logger.i('new-offer event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for new-offer
  void offNewOffer() {
    _logger.i('Removing new-offer listener');
    _socket?.off('new-offer');
  }

  Future<bool> emitAcceptRide({required String rideId, required String driverId}) async =>
      (await request('accept-ride', {'rideId': rideId, 'driverId': driverId})).ok;

  // Listen for ride picked up (for drivers - when passenger is picked up)
  void onRidePickedUp(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register ride-picked-up listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering ride-picked-up listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('ride-picked-up', (data) {
      _logger.i('ride-picked-up event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for ride picked up
  void offRidePickedUp() {
    _logger.i('Removing ride-picked-up listener');
    _socket?.off('ride-picked-up');
  }

  // Listen for payment-confirmed (for passengers - when driver confirms cash payment received)
  void onPaymentConfirmed(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register payment-confirmed listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering payment-confirmed listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('payment-confirmed', (data) {
      _logger.i('payment-confirmed event received in service: $data');
      handler(data);
    });
  }

  void offPaymentConfirmed() {
    _logger.i('Removing payment-confirmed listener');
    _socket?.off('payment-confirmed');
  }

  /// A card payment the server tried for the rider was declined.
  void onPaymentFailed(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register payment-failed listener - socket is null!');
      return;
    }
    _socket!.on('payment-failed', (data) => handler(data));
  }

  void offPaymentFailed() {
    _socket?.off('payment-failed');
  }

  void onRideUnavailable(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register ride-unavailable listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering ride-unavailable listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('ride-unavailable', (data) {
      _logger.i('ride-unavailable event received in service: $data');
      handler(data);
    });
  }

  void offRideUnavailable() {
    _logger.i('Removing ride-unavailable listener');
    _socket?.off('ride-unavailable');
  }

  // Listen for ride-completed (for passengers - when ride is completed)
  void onRideCompleted(Function(dynamic) handler) {
    if (_socket == null) {
      _logger.e('Cannot register ride-completed listener - socket is null!');
      return;
    }
    _logger.i(
      'Registering ride-completed listener, socket connected: ${_socket!.connected}',
    );
    _socket!.on('ride-completed', (data) {
      _logger.i('ride-completed event received in service: $data');
      handler(data);
    });
  }

  // Stop listening for ride-completed
  void offRideCompleted() {
    _logger.i('Removing ride-completed listener');
    _socket?.off('ride-completed');
  }

  // Listen for incompleted-ride (sent by server at the instant of connection).
  // Because the event arrives before onConnect fires, it is buffered internally
  // in connect(). Registering here replays the buffer immediately if already received.
  void onIncompletedRide(Function(dynamic) handler) {
    _incompletedRideHandler = handler;
    if (_incompletedRideBuffer != null) {
      _logger.i('Replaying buffered incompleted-ride event');
      handler(_incompletedRideBuffer);
      _incompletedRideBuffer = null;
    } else {
      _logger.i('incompleted-ride handler registered, waiting for event');
    }
  }

  // Stop listening for incompleted-ride
  void offIncompletedRide() {
    _logger.i('Removing incompleted-ride listener');
    _incompletedRideHandler = null;
    _incompletedRideBuffer = null;
  }
}
