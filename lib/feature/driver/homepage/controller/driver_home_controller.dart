import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/feature/driver/trip_flow/model/ride_request_model.dart';
import 'package:ride_sharing/feature/driver/trip_flow/view/trip_completion_payment_dialogs.dart';
import 'package:ride_sharing/feature/driver/trip_flow/view/driver_trip_flow.dart';
import 'package:ride_sharing/services/location_service.dart';
import 'package:ride_sharing/services/map_camera_mixin.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/services/ride_session_controller.dart';
import 'package:ride_sharing/services/maps_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class DriverHomeScreenController extends GetxController
    with MapCameraMixin, WidgetsBindingObserver {
  final Logger _logger = Logger();
  final TextEditingController locationTEController = TextEditingController();
  Position? currentPosition;
  bool isLoading = true;
  Set<Marker> markers = {};
  Set<Circle> circles = {};

  // Ride request state
  final Rx<RideRequestModel?> currentRideRequest = Rx<RideRequestModel?>(null);
  final RxBool hasNewRideRequest = false.obs;

  // Ride accepted state
  final RxBool isRideAccepted = false.obs;
  final RxString acceptedRideId = ''.obs;
  final RxString acceptedRiderId = ''.obs;

  // Ride picked up state (after driver confirms pickup)
  final RxBool isRidePickedUp = false.obs;

  // Polyline state for navigation
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxBool isNavigatingToPickup = false.obs;
  LatLng? pickupLocation;
  String? pickupName;
  LatLng? destinationLocation;
  String? destinationName;
  StreamSubscription<Position>? _locationSubscription;
  Worker? _rideSnapshotWorker;

  // Route tracking for snap-to-route and rotation
  List<LatLng> _currentRoutePoints = [];
  double _currentBearing = 0.0;
  int _currentRouteSegmentIndex = 0;

  // Turn-by-turn navigation
  final RxString currentStepInstruction = ''.obs;
  final RxString currentStepDistance = ''.obs;
  /// The current step and the ones after it, for the directions list.
  final RxList<({String instruction, String distance, String maneuver})>
      upcomingSteps = <({String instruction, String distance, String maneuver})>[].obs;
  List<Map<String, dynamic>> _routeSteps = [];
  int _currentStepIndex = 0;

  // Location update service & timer (when driver is online)
  Timer? _locationUpdateTimer;
  static const Duration _locationUpdateInterval = Duration(seconds: 20);

  // Idle GPS tracking (when online, no active route)
  StreamSubscription<Position>? _idleLocationSubscription;
  LatLng? _previousIdlePosition;

  // Simulation mode for testing/demo
  final RxBool isSimulationMode = false.obs;
  Timer? _simulationTimer;
  int _simulationPointIndex = 0;
  double _simulationProgress = 0.0; // 0.0 to 1.0 between two points
  static const double _simulationSpeed = 0.05; // Progress per tick (adjust for speed)
  static const int _simulationIntervalMs = 50; // Timer interval in milliseconds



  // Custom markers
  BitmapDescriptor? _pickupMarkerIcon;
  BitmapDescriptor? _driverMarkerIcon;

  // Store original car image for rotation
  ui.Image? _carImage;
  int _carImageSize = 50;

  // Offset to correct for the car image's natural orientation.
  // 0° assumes the image faces north. Adjust if the car faces another direction:
  //   image faces east  → set to -90.0
  //   image faces south → set to -180.0
  //   image faces west  → set to  90.0
  static const double _imageNorthOffsetDegrees = 0.0;

  // Shown once per screen visit — a retry on resume stays silent.
  bool _hasExplainedAccess = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadCustomMarkers();
    _initializeMap();
    _setupSocketListeners();
    _rideSnapshotWorker = ever<RideSnapshot?>(RideSessionController.to.ride,
        _applyRideSnapshot);
    _applyRideSnapshot(RideSessionController.to.ride.value);
  }

  void _applyRideSnapshot(RideSnapshot? snapshot) {
    if (snapshot == null) return;
    final data = snapshot.data;
    if (snapshot.status == 'CANCELLED' || snapshot.status == 'PAID') {
      if (currentRideRequest.value?.rideId == snapshot.rideId) clearRideRequest();
      clearRideAccepted();
      clearRidePickedUp();
      return;
    }
    if (snapshot.status == 'COMPLETED') return;
    if (snapshot.driverId == null) return;
    final request = RideRequestModel.fromJson({
      ...data,
      'rider': data['rider'] ?? {'name': AppLocalization.tr.riderFallbackName},
      'note': data['note'] ?? '',
      'rideNeeds': data['rideNeeds'] ?? <String>[],
      'riderNumber': data['riderNumber'] ?? '',
      'rideFor': data['rideFor'] ?? '',
    });
    currentRideRequest.value = request;
    acceptedRideId.value = snapshot.rideId;
    acceptedRiderId.value = snapshot.riderId;
    isRideAccepted.value = true;
    isRidePickedUp.value = snapshot.status == 'ONGOING' ||
        snapshot.status == 'COMPLETED';
    update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _logger.i('App resumed — checking socket connection');
      _reconnectSocketIfNeeded();

      // Permission may have been granted in Settings while we were away;
      // without this the map stays on the fallback camera all session.
      if (currentPosition == null) _initializeMap();
    }
  }

  Future<void> _reconnectSocketIfNeeded() async {
    final socketService = SocketIoService.to;
    if (!socketService.isSocketReady) {
      _logger.i('Socket disconnected after background — reconnecting...');
      await socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
      await _setupSocketListeners();
      _logger.i('Socket reconnected and listeners re-registered');
    } else {
      _logger.i('Socket still connected after resume — no action needed');
    }
  }

  Future<void> _loadCustomMarkers() async {
    try {
      _pickupMarkerIcon = await _getBitmapDescriptorFromAsset(
        'assets/images/location_pin.png',
        50, // width
      );
      _logger.i('Pickup marker icon loaded');

      // Load and store the car image for rotation
      _carImage = await _loadCarImage('assets/images/3D_car.png', _carImageSize);
      _driverMarkerIcon = await _getRotatedCarBitmap(0); // Initial rotation 0
      _logger.i('Driver marker icon loaded');

      _logger.i('Custom markers loaded successfully');

      // Update markers if they already exist
      if (markers.isNotEmpty && currentPosition != null) {
        await _updateDriverMarker();
      }
    } catch (e, stackTrace) {
      _logger.e('Error loading custom markers: $e');
      _logger.e('Stack trace: $stackTrace');
    }
  }

  // Load car image and store it for rotation
  Future<ui.Image> _loadCarImage(String assetPath, int width) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  // Create a rotated bitmap descriptor from the car image
  Future<BitmapDescriptor> _getRotatedCarBitmap(double rotationDegrees) async {
    _logger.i('🎨 [BITMAP] called with bearing=${rotationDegrees.toStringAsFixed(1)}°, offset=$_imageNorthOffsetDegrees°, carImage=${_carImage != null ? "loaded(${_carImage!.width}x${_carImage!.height})" : "NULL"}');

    if (_carImage == null) {
      _logger.e('🎨 [BITMAP] ❌ _carImage is null — returning default green marker. Check assets/images/3D_car.png is in pubspec.yaml');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    final int imageWidth = _carImage!.width;
    final int imageHeight = _carImage!.height;

    // Calculate the size needed for the rotated image (diagonal of original)
    final double diagonal = math.sqrt(imageWidth * imageWidth + imageHeight * imageHeight);
    final int canvasSize = diagonal.ceil();

    final double finalRotation = (rotationDegrees + _imageNorthOffsetDegrees) % 360;

    final double rotationRadians = finalRotation * math.pi / 180;

    _logger.i('🎨 [BITMAP] canvas=${canvasSize}px, finalRotation=${finalRotation.toStringAsFixed(1)}°');

    // Create a picture recorder and canvas
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.toDouble(), canvasSize.toDouble()));

    // Calculate center offset
    final double centerX = canvasSize / 2.0;
    final double centerY = canvasSize / 2.0;

    // Save canvas state
    canvas.save();

    // Move to center of canvas
    canvas.translate(centerX, centerY);

    // Rotate around center
    canvas.rotate(rotationRadians);

    // Draw image centered at origin (which is now the center of canvas, rotated)
    canvas.drawImage(
      _carImage!,
      Offset(-imageWidth / 2.0, -imageHeight / 2.0),
      Paint()..filterQuality = FilterQuality.high,
    );

    // Restore canvas state
    canvas.restore();

    // Convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image rotatedImage = await picture.toImage(canvasSize, canvasSize);
    final ByteData? byteData = await rotatedImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      _logger.e('🎨 [BITMAP] ❌ toByteData returned null — returning default marker');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    _logger.i('🎨 [BITMAP] ✅ success — ${byteData.lengthInBytes} bytes, rotation=${finalRotation.toStringAsFixed(1)}°');
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromAsset(String assetPath, int width) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedImageData = byteData!.buffer.asUint8List();
    return BitmapDescriptor.bytes(resizedImageData);
  }

  Future<void> _updateDriverMarker() async {
    if (currentPosition == null) return;

    // Get rotated car bitmap based on current bearing
    final rotatedIcon = await _getRotatedCarBitmap(_currentBearing);

    markers.removeWhere((m) => m.markerId.value == 'driver_location');
    markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        icon: rotatedIcon,
        infoWindow: InfoWindow(title: AppLocalization.tr.youMarkerLabel),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ),
    );
    update();
  }

  // Calculate bearing (angle) between two points in degrees
  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final diffLng = (to.longitude - from.longitude) * math.pi / 180;

    final x = math.sin(diffLng) * math.cos(lat2);
    final y = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(diffLng);

    final bearing = math.atan2(x, y);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  // Find the closest point on the route and return snapped position with bearing
  ({LatLng position, double bearing, int segmentIndex}) _snapToRouteWithBearing(LatLng currentPosition) {
    if (_currentRoutePoints.isEmpty) {
      return (position: currentPosition, bearing: _currentBearing, segmentIndex: 0);
    }

    double minDistance = double.infinity;
    LatLng closestPoint = currentPosition;
    int closestSegmentIndex = _currentRouteSegmentIndex;

    // Search from current segment onwards (driver moves forward)
    // Also check a few segments back in case of GPS drift
    final startIndex = math.max(0, _currentRouteSegmentIndex - 2);

    for (int i = startIndex; i < _currentRoutePoints.length; i++) {
      final point = _currentRoutePoints[i];
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
        closestSegmentIndex = i;
      }
    }

    // Calculate bearing to next point on route
    double bearing = _currentBearing;
    if (closestSegmentIndex < _currentRoutePoints.length - 1) {
      bearing = _calculateBearing(
        closestPoint,
        _currentRoutePoints[closestSegmentIndex + 1],
      );
    }

    _logger.i('Snapped to route point $closestSegmentIndex, distance: ${minDistance.toStringAsFixed(1)}m, bearing: ${bearing.toStringAsFixed(1)}°');

    return (position: closestPoint, bearing: bearing, segmentIndex: closestSegmentIndex);
  }

  // Update driver marker with position and rotated bitmap
  Future<void> _updateDriverMarkerWithRotation(LatLng position, double bearing) async {
    _logger.i('📍 [MARKER UPDATE] bearing=${bearing.toStringAsFixed(1)}°, pos=${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}');

    final rotatedIcon = await _getRotatedCarBitmap(bearing);

    final newMarker = Marker(
      markerId: const MarkerId('driver_location'),
      position: position,
      icon: rotatedIcon,
      infoWindow: InfoWindow(title: AppLocalization.tr.youMarkerLabel),
      anchor: const Offset(0.5, 0.5),
      flat: true,
    );

    final updatedMarkers = markers.where((m) => m.markerId.value != 'driver_location').toSet();
    updatedMarkers.add(newMarker);
    markers = updatedMarkers;

    _logger.i('📍 [MARKER UPDATE] ✅ markers set size=${markers.length}, icon.hashCode=${rotatedIcon.hashCode}');
  }

  Future<void> _setupSocketListeners() async {
    try {
      final socketService = SocketIoService.to;

      _logger.i('Setting up socket listeners...');
      _logger.i('Current socket status - isConnected: ${socketService.isConnected.value}, isSocketReady: ${socketService.isSocketReady}');

      // Connect to socket if not connected
      if (!socketService.isConnected.value) {
        _logger.i('Socket not connected, connecting...');
        await socketService.connect();

        // Wait for connection to establish
        await Future.delayed(const Duration(milliseconds: 500));
        _logger.i('After connect - isConnected: ${socketService.isConnected.value}, isSocketReady: ${socketService.isSocketReady}');
      }

      // Verify socket is ready before setting up listeners
      if (!socketService.isSocketReady) {
        _logger.w('Socket still not ready, retrying connection...');
        await socketService.connect();
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      if (!socketService.isSocketReady) {
        _logger.e('Socket failed to connect after retry');
        return;
      }

      _logger.i('Socket is ready, setting up listeners');

      // Set up the ride-request listener
      socketService.onRideRequest((data) {
        _logger.i('Ride request received: $data');
        _handleRideRequest(data);
      });

      // Set up the ride-accepted listener
      socketService.onRideAccepted((data) {
        _logger.i('Ride accepted received: $data');
        _handleRideAccepted(data);
      });

      // Set up the ride-picked-up listener
      socketService.onRidePickedUp((data) {
        _logger.i('Ride picked up received: $data');
        _handleRidePickedUp(data);
      });

      // Set up the payment-confirmed listener
      socketService.onPaymentConfirmed((data) {
        _logger.i('Payment confirmed received: $data');

        // Clear polyline, destination marker, circle and label from the map
        polylines.clear();
        circles = {};
        markers.removeWhere((m) =>
            m.markerId.value == 'destination_location' ||
            m.markerId.value == 'destination_radius_label');
        update();

        AppSnackbar.snackbar(
          AppLocalization.tr.paymentConfirmedTitle,
          AppLocalization.tr.passengerCompletedPaymentMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      });

      // Set up the ride-unavailable listener
      socketService.onRideUnavailable((data) {
        _logger.i('ride-unavailable received: $data');
        final message = (data is Map ? data['message'] as String? : null) ??
            AppLocalization.tr.rideNoLongerAvailableMessage;
        final incomingRideId = data is Map ? data['rideId'] as String? : null;

        final ctx = Get.context;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              duration: const Duration(seconds: 4),
              elevation: 8,
            ),
          );
        }

        // Remove the cancelled ride from PendingTripsBottomSheet
        if (incomingRideId != null &&
            currentRideRequest.value?.rideId == incomingRideId) {
          clearRideRequest();
          try {
            final tripController = Get.find<DriverTripController>();
            tripController.pendingTrips
                .removeWhere((t) => t.id == incomingRideId);
            if (tripController.pendingTrips.isEmpty) {
              tripController.selectedTrip.value = null;
              tripController.currentState.value = TripState.pendingRequests;
            }
          } catch (_) {
            // DriverTripController not mounted — no trip sheet open
          }
        }
      });

      // Set up the incompleted-ride listener (fires on reconnect when a ride is still incomplete)
      socketService.onIncompletedRide((data) {
        _logger.i('incompleted-ride received: $data');
        _handleIncompletedRide(data);
      });

      _logger.i('Socket listeners set up successfully - ride-request, ride-accepted, ride-picked-up, payment-confirmed, ride-unavailable, incompleted-ride');
    } catch (e) {
      _logger.e('Error setting up socket listeners: $e');
    }
  }

  Future<void> _handleRideAccepted(dynamic data) async {
    try {
      if (data != null && data is Map<String, dynamic>) {
        acceptedRideId.value = data['rideId'] ?? '';
        acceptedRiderId.value = data['riderId'] ?? '';
        isRideAccepted.value = true;

        _logger.i('Ride accepted - rideId: ${acceptedRideId.value}, riderId: ${acceptedRiderId.value}');

        // Immediately show route from driver's current location to pickup
        final rideRequest = currentRideRequest.value;
        if (rideRequest != null) {
          _logger.i('Showing route to pickup on ride-accepted: ${rideRequest.pickUp.name} [${rideRequest.pickUp.latitude}, ${rideRequest.pickUp.longitude}]');
          await showRouteToPickup(
            pickupLat: rideRequest.pickUp.latitude,
            pickupLng: rideRequest.pickUp.longitude,
            pickupName: rideRequest.pickUp.name,
          );
        } else {
          _logger.e('No stored ride request - cannot show pickup route');
        }

        update();
      }
    } catch (e) {
      _logger.e('Error handling ride accepted: $e');
    }
  }

  void clearRideAccepted() {
    isRideAccepted.value = false;
    acceptedRideId.value = '';
    acceptedRiderId.value = '';
    update();
  }

  void clearRidePickedUp() {
    isRidePickedUp.value = false;
    update();
  }

  void _handleRideRequest(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        currentRideRequest.value = RideRequestModel.fromJson(data);
        hasNewRideRequest.value = true;

        // Store destination location for later use (when ride-picked-up is received)
        final destination = currentRideRequest.value!.destination;
        destinationLocation = LatLng(destination.latitude, destination.longitude);
        destinationName = destination.name;
        _logger.i('Stored destination: $destinationName at [${destination.longitude}, ${destination.latitude}]');

        _logger.i('Ride request parsed successfully: ${currentRideRequest.value?.rideId}');
        update();
      }
    } catch (e) {
      _logger.e('Error parsing ride request: $e');
    }
  }

  void clearRideRequest() {
    currentRideRequest.value = null;
    hasNewRideRequest.value = false;
    update();
  }

  Future<void> _handleRidePickedUp(dynamic data) async {
    try {
      _logger.i('Handling ride-picked-up event - setting isRidePickedUp for state transition');
      // Route to destination is already shown from confirmPickup() in DriverTripController
      isRidePickedUp.value = true;
    } catch (e) {
      _logger.e('Error handling ride picked up: $e');
    }
  }

  void _handleIncompletedRide(dynamic data) {
    try {
      if (data == null || data is! Map<String, dynamic>) return;

      final status = data['status'] as String? ?? '';
      final isPaymentCompleted = data['isPaymentCompleted'] as bool? ?? true;

      if (status != 'COMPLETED' || isPaymentCompleted) return;

      final rideId = data['_id'] as String? ?? '';
      _logger.i('Incompleted ride detected on reconnect — status: $status, rideId: $rideId. Showing PaymentConfirmationDialog.');

      // The buffered event is replayed synchronously when the listener is
      // registered, which happens while this controller is created during a
      // build. Pushing a dialog then breaks the navigator ('!_debugLocked'),
      // so wait for the frame to finish.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showIncompletedRidePaymentDialog(rideId),
      );
    } catch (e) {
      _logger.e('Error handling incompleted-ride: $e');
    }
  }

  void _showIncompletedRidePaymentDialog(String rideId) {
    try {
      final context = Get.context;
      if (context == null) return;

      TripDialogs.showTripCompletion(
        context,
        onBackToHome: () {
          Get.back();
          _logger.i('Awaiting server-confirmed rider payment for rideId: $rideId');
        },
      );
    } catch (e) {
      _logger.e('Error handling incompleted-ride: $e');
    }
  }

  // Show route from pickup location to destination with polyline
  Future<void> showRouteToDestination({
    required double destinationLat,
    required double destinationLng,
    required String destinationName,
  }) async {
    _logger.i('showRouteToDestination called - destinationLat: $destinationLat, destinationLng: $destinationLng, destinationName: $destinationName');

    if (currentPosition == null) {
      _logger.e('No current position - cannot show route to destination');
      return;
    }

    destinationLocation = LatLng(destinationLat, destinationLng);
    this.destinationName = destinationName;

    // Reset route tracking for new route
    _currentRoutePoints = [];
    _currentRouteSegmentIndex = 0;

    // Reset turn-by-turn navigation
    _routeSteps = [];
    _currentStepIndex = 0;
    currentStepInstruction.value = AppLocalization.tr.navigatingLabel;
    currentStepDistance.value = '';
    upcomingSteps.clear();

    // Add destination marker
    markers.removeWhere((m) => m.markerId.value == 'destination_location');
    markers.add(
      Marker(
        markerId: const MarkerId('destination_location'),
        position: LatLng(destinationLat, destinationLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: AppLocalization.tr.destination, snippet: destinationName),
      ),
    );
    _logger.i('Destination marker added. Total markers: ${markers.length}');

    // Draw 500m radius circle around destination with text label
    circles = {
      Circle(
        circleId: const CircleId('destination_radius'),
        center: LatLng(destinationLat, destinationLng),
        radius: 500,
        fillColor: Colors.blue.withOpacity(0.15),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    };
    final labelIcon = await _createRadiusLabelBitmap('500m radius');
    const double offsetDeg = 0.0045; // ≈ 500 m in latitude degrees
    markers.removeWhere((m) => m.markerId.value == 'destination_radius_label');
    markers.add(
      Marker(
        markerId: const MarkerId('destination_radius_label'),
        position: LatLng(destinationLat + offsetDeg, destinationLng),
        icon: labelIcon,
        anchor: const Offset(0.5, 1.0),
        flat: true,
      ),
    );

    // Get and draw route from pickup to destination - AWAIT this!
    await _getRoutePickupToDestination();
    _logger.i('Route fetched. Route points count: ${_currentRoutePoints.length}');

    // Start location tracking for destination route AFTER route is fetched
    _startLocationTracking();

    // Move camera to show both locations
    _fitPickupAndDestination();

    _logger.i('Calling update() after showRouteToDestination setup');
    update();
  }

  // Show route from current location to pickup with polyline
  Future<void> showRouteToPickup({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
  }) async {
    _logger.i('showRouteToPickup called - pickupLat: $pickupLat, pickupLng: $pickupLng, pickupName: $pickupName');
    _logger.i('Current position: $currentPosition');

    this.pickupLocation = LatLng(pickupLat, pickupLng);
    this.pickupName = pickupName;
    isNavigatingToPickup.value = true;

    // Reset route tracking for new route
    _currentRoutePoints = [];
    _currentRouteSegmentIndex = 0;

    // Add pickup marker with custom icon
    markers.add(
      Marker(
        markerId: const MarkerId('pickup_location'),
        position: LatLng(pickupLat, pickupLng),
        icon: _pickupMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: AppLocalization.tr.pickupLabel, snippet: pickupName),
      ),
    );
    _logger.i('Pickup marker added. Total markers: ${markers.length}');

    // Get and draw route from current location to pickup - AWAIT this!
    await _getRouteToPickup();
    _logger.i('Route fetched. Route points count: ${_currentRoutePoints.length}');

    // Start real-time location tracking AFTER route is fetched
    _startLocationTracking();

    // Move camera to show both locations
    _fitBothLocations();

    _logger.i('Calling update() after showRouteToPickup setup');
    update();
  }

  Future<void> _getRoutePickupToDestination() async {
    if (currentPosition == null || destinationLocation == null) {
      _logger.e('Cannot get route - missing current position or destination location');
      return;
    }

    try {
      final data = await MapsService().directions(
        currentPosition!.latitude, currentPosition!.longitude,
        destinationLocation!.latitude, destinationLocation!.longitude);
        _logger.i('Directions API status: ${data['status']}');
        if (data['error_message'] != null) {
          _logger.e('API Error Message: ${data['error_message']}');
        }

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylinePoints = _decodePolyline(points);

          // Store route points for snap-to-route and bearing calculation
          _currentRoutePoints = polylinePoints;
          _currentRouteSegmentIndex = 0;

          // Parse turn-by-turn navigation steps
          _routeSteps = [];
          _currentStepIndex = 0;
          final legs = data['routes'][0]['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final steps = legs[0]['steps'] as List?;
            if (steps != null) {
              _routeSteps = steps.map((s) => Map<String, dynamic>.from(s as Map)).toList();
              _logger.i('Parsed ${_routeSteps.length} navigation steps');
            }
          }
          _updateCurrentStep();

          polylines.value = {
            Polyline(
              polylineId: const PolylineId('route_pickup_to_destination'),
              points: polylinePoints,
              color: Colors.black,
              width: 5,
            ),
          };

          _logger.i('Route polyline drawn with ${polylinePoints.length} points');
          update();
        } else {
          _logger.e('No routes found: ${data['status']}');
          // Fallback: draw straight line
          _drawStraightLinePickupToDestination();
        }
    } catch (e) {
      _logger.e('Error fetching route: $e');
      _drawStraightLinePickupToDestination();
    }
  }

  Future<void> _getRouteToPickup() async {
    _logger.i('_getRouteToPickup called - currentPosition: $currentPosition, pickupLocation: $pickupLocation');

    if (currentPosition == null || pickupLocation == null) {
      _logger.e('Cannot get route - missing current position or pickup location');
      return;
    }

    try {
      final data = await MapsService().directions(
        currentPosition!.latitude, currentPosition!.longitude,
        pickupLocation!.latitude, pickupLocation!.longitude);
        _logger.i('Directions API response status: ${data['status']}');
        if (data['error_message'] != null) {
          _logger.e('API Error Message: ${data['error_message']}');
        }

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylinePoints = _decodePolyline(points);

          _logger.i('Decoded ${polylinePoints.length} polyline points');

          // Store route points for snap-to-route and bearing calculation
          _currentRoutePoints = polylinePoints;
          _currentRouteSegmentIndex = 0;

          polylines.value = {
            Polyline(
              polylineId: const PolylineId('route_to_pickup'),
              points: polylinePoints,
              color: Colors.black,
              width: 5,
            ),
          };

          _logger.i('Polylines set. Current polylines count: ${polylines.value.length}');
          _logger.i('Calling update() after setting polylines');
          update();
        } else {
          _logger.e('No routes found: ${data['status']}');
          // Fallback: draw straight line
          _drawStraightLine();
        }
    } catch (e) {
      _logger.e('Error fetching route: $e');
      _drawStraightLine();
    }
  }

  // Decode Google's encoded polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Strip HTML tags from Google's html_instructions
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Update reactive navigation step fields from current step index
  void _updateCurrentStep() {
    upcomingSteps.assignAll([
      for (final step in _routeSteps.skip(_currentStepIndex))
        (
          instruction: _stripHtml(step['html_instructions'] as String? ?? ''),
          distance: (step['distance'] as Map?)?['text'] as String? ?? '',
          maneuver: step['maneuver'] as String? ?? '',
        ),
    ]);
    if (_routeSteps.isEmpty) {
      currentStepInstruction.value = AppLocalization.tr.navigatingLabel;
      currentStepDistance.value = '';
      return;
    }

    if (_currentStepIndex >= _routeSteps.length) {
      currentStepInstruction.value = AppLocalization.tr.arrivingAtDestinationLabel;
      currentStepDistance.value = '';
      return;
    }

    final step = _routeSteps[_currentStepIndex];
    final rawInstruction = step['html_instructions'] as String? ?? '';
    final instruction = _stripHtml(rawInstruction);

    final distanceMap = step['distance'] as Map?;
    final distanceText = distanceMap?['text'] as String? ?? '';

    currentStepInstruction.value = instruction;
    currentStepDistance.value = distanceText;

    _logger.i('Nav step $_currentStepIndex/${_routeSteps.length}: $distanceText - $instruction');
  }

  // Fallback: draw straight line if API fails
  void _drawStraightLine() {
    _logger.i('_drawStraightLine called - currentPosition: $currentPosition, pickupLocation: $pickupLocation');

    if (currentPosition == null || pickupLocation == null) {
      _logger.e('Cannot draw straight line - missing position data');
      return;
    }

    final startPoint = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    final endPoint = pickupLocation!;

    // Set route points for fallback (straight line has just 2 points)
    _currentRoutePoints = [startPoint, endPoint];
    _currentRouteSegmentIndex = 0;

    polylines.value = {
      Polyline(
        polylineId: const PolylineId('route_to_pickup'),
        points: [startPoint, endPoint],
        color: Colors.black,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };

    _logger.i('Drew straight line fallback. Polylines count: ${polylines.value.length}, route points: ${_currentRoutePoints.length}');
    update();
  }

  // Fallback: draw straight line from current position to destination if API fails
  void _drawStraightLinePickupToDestination() {
    if (currentPosition == null || destinationLocation == null) return;

    final startPoint = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    final endPoint = destinationLocation!;

    // Set route points for fallback (straight line has just 2 points)
    _currentRoutePoints = [startPoint, endPoint];
    _currentRouteSegmentIndex = 0;

    polylines.value = {
      Polyline(
        polylineId: const PolylineId('route_pickup_to_destination'),
        points: [startPoint, endPoint],
        color: Colors.black,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };

    _logger.i('Drew straight line fallback from pickup to destination. Route points: ${_currentRoutePoints.length}');
    update();
  }

  // Fit camera to show both pickup and destination
  void _fitPickupAndDestination() {
    if (mapController == null || pickupLocation == null || destinationLocation == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        pickupLocation!.latitude < destinationLocation!.latitude
            ? pickupLocation!.latitude
            : destinationLocation!.latitude,
        pickupLocation!.longitude < destinationLocation!.longitude
            ? pickupLocation!.longitude
            : destinationLocation!.longitude,
      ),
      northeast: LatLng(
        pickupLocation!.latitude > destinationLocation!.latitude
            ? pickupLocation!.latitude
            : destinationLocation!.latitude,
        pickupLocation!.longitude > destinationLocation!.longitude
            ? pickupLocation!.longitude
            : destinationLocation!.longitude,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void _startLocationTracking() {
    _logger.i('Starting real-time location tracking');
    _logger.i('Route points available: ${_currentRoutePoints.length}');

    // Stop idle tracking — active navigation takes over
    _stopIdleLocationTracking();
    _locationSubscription?.cancel();

    _locationSubscription =
        LocationService.positionStream(distanceFilter: 1).listen((
      Position position,
    ) async {
      _logger.i('🚗 [GPS] lat=${position.latitude.toStringAsFixed(6)}, lng=${position.longitude.toStringAsFixed(6)}, accuracy=${position.accuracy.toStringAsFixed(1)}m');
      _logger.i('🚗 [GPS] routePoints=${_currentRoutePoints.length}, currentBearing=${_currentBearing.toStringAsFixed(1)}°');

      currentPosition = position;

      // Emit update-location socket event with current GPS position
      await SocketIoService.to.emitUpdateLocation(
        locationName: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      if (_currentRoutePoints.isNotEmpty) {
        final snappedResult = _snapToRouteWithBearing(currentLatLng);

        _currentBearing = snappedResult.bearing;
        _currentRouteSegmentIndex = snappedResult.segmentIndex;

        _logger.i('🧭 [SNAP] snappedSegment=${snappedResult.segmentIndex}/${_currentRoutePoints.length}, bearing=${snappedResult.bearing.toStringAsFixed(1)}°');

        await _updateDriverMarkerWithRotation(snappedResult.position, snappedResult.bearing);

        _logger.i('📍 [MARKER] updated at snapped position, bearing=${snappedResult.bearing.toStringAsFixed(1)}°');

        // Advance navigation step based on proximity to step end location
        if (_routeSteps.isNotEmpty && _currentStepIndex < _routeSteps.length) {
          final step = _routeSteps[_currentStepIndex];
          final endLocation = step['end_location'] as Map?;
          if (endLocation != null) {
            final stepEndLat = (endLocation['lat'] as num).toDouble();
            final stepEndLng = (endLocation['lng'] as num).toDouble();
            final distanceToStepEnd = Geolocator.distanceBetween(
              position.latitude, position.longitude,
              stepEndLat, stepEndLng,
            );
            if (distanceToStepEnd < 30) {
              _currentStepIndex++;
              _updateCurrentStep();
            }
          }
        }
      } else {
        _logger.w('No route points available - marker will not rotate');
        final icon = await _getRotatedCarBitmap(_currentBearing);
        markers.removeWhere((m) => m.markerId.value == 'driver_location');
        markers.add(
          Marker(
            markerId: const MarkerId('driver_location'),
            position: currentLatLng,
            icon: icon,
            infoWindow: InfoWindow(title: AppLocalization.tr.youMarkerLabel),
            anchor: const Offset(0.5, 0.5),
            flat: true,
          ),
        );
      }


      update();
    });
  }

  // ==================== SIMULATION MODE ====================

  /// Start simulation mode - car auto-moves along the route
  void startSimulation() {
    if (_currentRoutePoints.isEmpty) {
      _logger.e('Cannot start simulation - no route points available');
      return;
    }

    _logger.i('Starting route simulation with ${_currentRoutePoints.length} points');

    // Stop real GPS tracking if active
    _locationSubscription?.cancel();
    _locationSubscription = null;

    // Reset simulation state
    _simulationPointIndex = 0;
    _simulationProgress = 0.0;
    isSimulationMode.value = true;

    // Start simulation timer
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: _simulationIntervalMs),
      (_) => _advanceSimulation(),
    );

    update();
  }

  /// Stop simulation mode
  void stopSimulation() {
    _logger.i('Stopping route simulation');

    _simulationTimer?.cancel();
    _simulationTimer = null;
    isSimulationMode.value = false;
    _simulationPointIndex = 0;
    _simulationProgress = 0.0;

    update();
  }

  /// Toggle simulation mode on/off
  void toggleSimulation() {
    if (isSimulationMode.value) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  /// Advance the simulation by one step
  Future<void> _advanceSimulation() async {
    if (_currentRoutePoints.isEmpty || _simulationPointIndex >= _currentRoutePoints.length - 1) {
      _logger.i('Simulation reached end of route');
      stopSimulation();
      return;
    }

    // Get current and next points
    final currentPoint = _currentRoutePoints[_simulationPointIndex];
    final nextPoint = _currentRoutePoints[_simulationPointIndex + 1];

    // Advance progress
    _simulationProgress += _simulationSpeed;

    // Check if we've reached the next point
    if (_simulationProgress >= 1.0) {
      _simulationProgress = 0.0;
      _simulationPointIndex++;

      if (_simulationPointIndex >= _currentRoutePoints.length - 1) {
        _logger.i('Simulation completed - reached destination');
        stopSimulation();
        return;
      }
    }

    // Interpolate position between current and next point
    final interpolatedPosition = _interpolatePosition(
      currentPoint,
      nextPoint,
      _simulationProgress,
    );

    // Calculate bearing to next point
    final bearing = _calculateBearing(currentPoint, nextPoint);

    // Update marker with interpolated position and rotation
    await _updateDriverMarkerWithRotation(interpolatedPosition, bearing);

    _logger.d('Simulation: point $_simulationPointIndex/${_currentRoutePoints.length - 1}, progress: ${(_simulationProgress * 100).toStringAsFixed(0)}%, bearing: ${bearing.toStringAsFixed(1)}°');

    update();
  }

  /// Interpolate between two LatLng points
  LatLng _interpolatePosition(LatLng from, LatLng to, double progress) {
    final lat = from.latitude + (to.latitude - from.latitude) * progress;
    final lng = from.longitude + (to.longitude - from.longitude) * progress;
    return LatLng(lat, lng);
  }

  /// Set simulation speed (0.01 = slow, 0.1 = fast)
  void setSimulationSpeed(double speed) {
    _logger.i('Setting simulation speed to $speed');
    // Note: This requires restarting simulation to take effect
    // For dynamic speed, you'd modify _simulationSpeed directly
  }

  // ==================== END SIMULATION MODE ====================

  void _fitBothLocations() {
    if (mapController == null || currentPosition == null || pickupLocation == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        currentPosition!.latitude < pickupLocation!.latitude
            ? currentPosition!.latitude
            : pickupLocation!.latitude,
        currentPosition!.longitude < pickupLocation!.longitude
            ? currentPosition!.longitude
            : pickupLocation!.longitude,
      ),
      northeast: LatLng(
        currentPosition!.latitude > pickupLocation!.latitude
            ? currentPosition!.latitude
            : pickupLocation!.latitude,
        currentPosition!.longitude > pickupLocation!.longitude
            ? currentPosition!.longitude
            : pickupLocation!.longitude,
      ),
    );

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  // ==================== ONLINE LOCATION UPDATES ====================

  /// Called when the driver goes online. Hits the API immediately then every 20 seconds.
  /// Also starts idle GPS tracking so the car icon moves/rotates before any ride.
  Future<void> startLocationUpdates() async {
    _logger.i('Driver went online — starting location updates every ${_locationUpdateInterval.inSeconds}s');
    await _postCurrentLocation(); // immediate hit
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (_) async {
      await _postCurrentLocation();
    });
    _startIdleLocationTracking();
  }

  /// Called when the driver goes offline. Stops the periodic timer and idle tracking.
  void stopLocationUpdates() {
    _logger.i('Driver went offline — stopping location updates');
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _stopIdleLocationTracking();
  }

  void _startIdleLocationTracking() {
    _logger.i('🟢 [IDLE TRACK] starting idle GPS tracking (distanceFilter=5m)');
    _idleLocationSubscription?.cancel();
    _previousIdlePosition = null;

    _idleLocationSubscription =
        LocationService.positionStream(distanceFilter: 5).listen((
      Position position,
    ) async {
      currentPosition = position;
      final currentLatLng = LatLng(position.latitude, position.longitude);

      if (_previousIdlePosition != null) {
        _currentBearing = _calculateBearing(_previousIdlePosition!, currentLatLng);
        _logger.i('🟢 [IDLE TRACK] moved — bearing=${_currentBearing.toStringAsFixed(1)}°, from=${_previousIdlePosition!.latitude.toStringAsFixed(6)} to=${currentLatLng.latitude.toStringAsFixed(6)}');
      } else {
        _logger.i('🟢 [IDLE TRACK] first fix — lat=${position.latitude.toStringAsFixed(6)}, bearing stays ${_currentBearing.toStringAsFixed(1)}°');
      }
      _previousIdlePosition = currentLatLng;

      await _updateDriverMarkerWithRotation(currentLatLng, _currentBearing);
      _logger.i('🟢 [IDLE TRACK] calling update()');
      update();
    });
  }

  void _stopIdleLocationTracking() {
    _idleLocationSubscription?.cancel();
    _idleLocationSubscription = null;
    _previousIdlePosition = null;
  }

  Future<void> _postCurrentLocation() async {
    if (currentPosition == null) {
      _logger.w('Cannot post location — currentPosition is null');
      return;
    }

    // The backend has no REST endpoint for this: a driver's location is only
    // stored through the `update-location` socket event, and nearest-driver
    // search reads that stored location.
    try {
      await SocketIoService.to.emitUpdateLocation(
        locationName: 'Current Location',
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
      );
    } catch (e) {
      _logger.e('Error posting current location: $e');
    }
  }

  // ==================== END ONLINE LOCATION UPDATES ====================

  void stopNavigation() {
    _logger.i('Stopping navigation');
    isNavigatingToPickup.value = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    polylines.clear();
    circles = {};
    markers.removeWhere((m) => m.markerId.value == 'destination_radius_label');

    // Stop simulation if running
    stopSimulation();

    // Clear route tracking data
    _currentRoutePoints = [];
    _currentRouteSegmentIndex = 0;
    _currentBearing = 0.0;

    // Reset turn-by-turn navigation
    _routeSteps = [];
    _currentStepIndex = 0;
    currentStepInstruction.value = AppLocalization.tr.navigatingLabel;
    currentStepDistance.value = '';
    upcomingSteps.clear();

    markers.removeWhere((m) => m.markerId.value == 'pickup_location');
    update();
  }

  Future<void> _initializeMap() async {
    final LocationAccess access = await LocationService.requestAccess();
    if (access != LocationAccess.granted) {
      isLoading = false;
      update();
      if (!_hasExplainedAccess) {
        _hasExplainedAccess = true;
        await LocationService.showAccessDialog(access);
      }
      return;
    }
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Position? position = await LocationService.readPosition();
      if (position == null) {
        _logger.w('No position available for the driver map');
        return;
      }

      currentPosition = position;

      // Get rotated car bitmap (initial bearing is 0)
      final rotatedIcon = await _getRotatedCarBitmap(_currentBearing);

      markers = {
        Marker(
          markerId: const MarkerId('driver_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: rotatedIcon,
          infoWindow: InfoWindow(title: AppLocalization.tr.youMarkerLabel),
          anchor: const Offset(0.5, 0.5),
          flat: true,
        ),
      };

      update(); // markers + position updated

      // Queued when the map isn't built yet, so the camera can't be left
      // behind by whichever of the two arrives first.
      moveCameraTo(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<BitmapDescriptor> _createRadiusLabelBitmap(String text) async {
    const double fontSize = 13;
    const double padding = 6;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double w = textPainter.width + padding * 2;
    final double h = textPainter.height + padding * 2;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

    // White rounded background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(6)),
      Paint()..color = Colors.white.withOpacity(0.9),
    );
    // Blue border
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(6)),
      Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    textPainter.paint(canvas, Offset(padding, padding));

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(w.ceil(), h.ceil());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  @override
  void onClose() {
    _rideSnapshotWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    disposeMapController();
    _locationSubscription?.cancel();
    _idleLocationSubscription?.cancel();
    _simulationTimer?.cancel();
    _locationUpdateTimer?.cancel();
    // Remove socket listeners
    SocketIoService.to.offRideRequest();
    SocketIoService.to.offRideAccepted();
    super.onClose();
  }
}
