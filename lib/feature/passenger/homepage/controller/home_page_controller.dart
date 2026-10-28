import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:ride_sharing/feature/passenger/payment/view/passenger_payment_screen.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/booking_car_bottomsheet.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/ride_begun_bottom_sheet.dart';
import 'package:ride_sharing/feature/passenger/trip_details/data/get_trip_details_model.dart';
import 'package:ride_sharing/feature/passenger/trip_details/service/trip_details_service.dart';
import 'package:ride_sharing/services/location_service.dart';
import 'package:ride_sharing/services/map_camera_mixin.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/services/ride_session_controller.dart';
import 'package:ride_sharing/services/maps_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

class HomePageController extends GetxController
    with MapCameraMixin, WidgetsBindingObserver {
  final TextEditingController locationTEController = TextEditingController();
  Position? currentPosition;
  bool isLoading = true;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Set<Circle> circles = {};

  // Non-modal bottom sheet support — allows map to remain touchable
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _currentSheetController;

  // True once a ride request has been created from the booking map; backing
  // out of the map is blocked from then on so the request isn't orphaned.
  bool rideRequestActive = false;
  Worker? _rideSnapshotWorker;
  String? _paymentRideShown;
  String? _restoredRideState;
  String? _cancelledRideShown;

  void showPassengerSheet(WidgetBuilder builder) {
    _currentSheetController?.close();
    final shown = scaffoldKey.currentState?.showBottomSheet(
      builder,
      backgroundColor: Colors.transparent,
      enableDrag: false,
    );
    _currentSheetController = shown;
    shown?.closed.whenComplete(() {
      if (identical(_currentSheetController, shown)) _currentSheetController = null;
    });
  }

  void closeCurrentSheet() {
    _currentSheetController?.close();
    _currentSheetController = null;
  }

  static const int _carImageSize = 40;

  // Adjust to match the car image's natural orientation (same value as driver controller).
  //   image faces east  → -90.0
  //   image faces south → -180.0
  //   image faces west  →  90.0
  static const double _imageNorthOffsetDegrees = 0.0;

  // Custom marker icons
  ui.Image? _carImage;
  BitmapDescriptor? _pinMarkerIcon;
  BitmapDescriptor? _smallCarIcon;

  // Route state for snap-to-route bearing
  List<LatLng> _currentRoutePoints = [];
  int _currentRouteSegmentIndex = 0;
  double _currentBearing = 0.0;

  // Tracks last position where Directions API was called — avoids redundant fetches
  LatLng? _lastFetchedDriverLocation;

  // Tracks previous driver position to compute movement bearing before route loads
  LatLng? _previousDriverPosition;

  // Live position stream — keeps the passenger marker/camera on the real
  // device location while no driver is being tracked.
  StreamSubscription<Position>? _positionSubscription;
  bool _followUserCamera = true;

  // The access dialogs are shown once per screen visit. A retry triggered by
  // the app coming back to the foreground stays silent, so a user who left
  // permission off isn't met with the same dialog after every app switch.
  bool _hasExplainedAccess = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Deferred to the first frame so Get.context exists — the permission
    // dialogs below are localized and need a BuildContext.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMap());
    _setupIncompletedRideListener();
    _rideSnapshotWorker = ever<RideSnapshot?>(RideSessionController.to.ride,
        _applyRideSnapshot);
    _applyRideSnapshot(RideSessionController.to.ride.value);
  }

  void _applyRideSnapshot(RideSnapshot? snapshot) {
    rideRequestActive = snapshot?.isActive ?? false;
    if (snapshot?.status == 'CANCELLED' && _cancelledRideShown != snapshot!.rideId) {
      _cancelledRideShown = snapshot.rideId;
      // Close the driver/trip sheet, whether the rider or the driver cancelled.
      closeCurrentSheet();
      _restoredRideState = null;
      AppSnackbar.snackbar(
        AppLocalization.tr.cancelTaxiTitle,
        AppLocalization.tr.rideCancelledMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    if (snapshot != null && _currentSheetController == null &&
        (snapshot.status == 'ACCEPTED' || snapshot.status == 'ONGOING') &&
        _restoredRideState != '${snapshot.rideId}:${snapshot.status}') {
      _restoredRideState = '${snapshot.rideId}:${snapshot.status}';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scaffoldKey.currentState == null || _currentSheetController != null) return;
        final driver = snapshot.data['driver'] is Map
            ? Map<String, dynamic>.from(snapshot.data['driver'] as Map)
            : <String, dynamic>{};
        final car = driver['carInformation'] is Map
            ? Map<String, dynamic>.from(driver['carInformation'] as Map)
            : <String, dynamic>{};
        final name = '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim();
        final destination = snapshot.data['destination'] is Map
            ? snapshot.data['destination'] as Map : const {};
        final pickup = snapshot.data['pickUp'] is Map
            ? snapshot.data['pickUp'] as Map : const {};
        if (snapshot.status == 'ONGOING') {
          showPassengerSheet((_) => RideBegunBottomSheet(
            driverName: name, driverProfilePicture: driver['profilePicture']?.toString(),
            driverRating: num.tryParse('${driver['rating']}')?.toDouble() ?? 0,
            driverTotalReviews: int.tryParse('${driver['totalReviews']}') ?? 0,
            bidAmount: snapshot.data['fare']?.toString() ?? '',
            tripDistance: snapshot.data['distance']?.toString() ?? '',
            destinationAddress: destination['name']?.toString() ?? '',
          ));
        } else {
          showPassengerSheet((_) => BookingCarsBottomSheet(
            rideId: snapshot.rideId, driverId: snapshot.driverId ?? '',
            driverName: name, driverProfilePicture: driver['profilePicture']?.toString(),
            driverRating: num.tryParse('${driver['rating']}')?.toDouble() ?? 0,
            driverTotalReviews: int.tryParse('${driver['totalReviews']}') ?? 0,
            carBrand: car['brand']?.toString() ?? '',
            carModel: car['model']?.toString() ?? '',
            licensePlateNumber: car['licensePlateNumber']?.toString() ?? '',
            bidAmount: snapshot.data['fare']?.toString() ?? '',
            tripDistance: snapshot.data['distance']?.toString() ?? '',
            pickUpAddress: pickup['name']?.toString() ?? '',
            destinationAddress: destination['name']?.toString() ?? '',
          ));
        }
      });
    }
    if (snapshot?.status == 'COMPLETED' &&
        _paymentRideShown != snapshot!.rideId) {
      _paymentRideShown = snapshot.rideId;
      _resumeIncompleteRide({...snapshot.data, '_id': snapshot.rideId});
    }
    update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // The user may have just granted permission — or switched location on —
    // in Settings. Without this retry the map would stay on the fallback
    // camera for the rest of the session.
    if (_positionSubscription == null) _startLocationTracking();
  }

  Future<void> _setupIncompletedRideListener() async {
    final socketService = SocketIoService.to;
    if (!socketService.isSocketReady) {
      await socketService.connect();
    }
    if (!socketService.isSocketReady) return;

    socketService.onIncompletedRide(_resumeIncompleteRide);
  }

  Future<void> _resumeIncompleteRide(dynamic data) async {
      if (data == null || data is! Map<String, dynamic>) return;

      final status = data['status'] as String? ?? '';
      final isPaymentCompleted = data['isPaymentCompleted'] as bool? ?? true;

      if (status != 'COMPLETED' || isPaymentCompleted) return;

      // Only navigate to PassengerPaymentScreen if this user is the RIDER of this ride.
      // The driver can also land on the passenger home screen — skip for them.
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final riderId = data['riderId'] as String? ?? '';
      if (userId.isEmpty || riderId != userId) return;

      final rideId = data['_id'] as String? ?? '';
      final driverId = data['driverId'] as String? ?? '';
      final paymentMethod = data['paymentMethod'] as String? ?? '';
      final pickUp = data['pickUp'] as Map<String, dynamic>?;
      final destination = data['destination'] as Map<String, dynamic>?;

      String driverName = '';
      String? driverProfilePicture;

      final response = await TripDetailsService().getTripDetails(rideId);
      if (response.isSuccess && response.responseData != null) {
        try {
          final details = GetTripDetailsModel.fromJson(
            response.responseData as Map<String, dynamic>,
          );
          driverName = details.data.driverId.name;
          driverProfilePicture = details.data.driverId.profilePicture;
        } catch (_) {}
      }

      Get.offAll(() => PassengerPaymentScreen(
        rideId: rideId,
        driverId: driverId,
        paymentMethod: paymentMethod,
        bidAmount: num.tryParse('${data['fare']}')?.toStringAsFixed(2) ?? '',
        tripDistance: data['distance']?.toString() ?? '',
        pickUpAddress: pickUp?['name'] as String? ?? '',
        destinationAddress: destination?['name'] as String? ?? '',
        driverName: driverName,
        driverProfilePicture: driverProfilePicture,
      ));
  }

  // @override
  // void onClose() {
  //   SocketIoService.to.offIncompletedRide();
  //   super.onClose();
  // }

  Future<void> _initializeMap() async {
    await _loadIcons();
    await _startLocationTracking();
  }

  /// Gets access, a first fix and the live stream running. Safe to call again
  /// — that is how a permission granted later in Settings is picked up.
  Future<void> _startLocationTracking() async {
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
    _startLiveLocationUpdates();
  }

  // ─── Icon loading ──────────────────────────────────────────────────────────

  Future<void> _loadIcons() async {
    try {
      _pinMarkerIcon = await _getBitmapDescriptorFromAsset(
        'assets/images/location_pin.png',
        40,
      );
      _carImage = await _loadCarImage('assets/images/3D_car.png', _carImageSize);
      _smallCarIcon = await _getBitmapDescriptorFromAsset(
        'assets/images/3D_car.png',
        _carImageSize,
      );
    } catch (_) {
      // Fallback to defaults if assets are missing
    }
  }

  Future<ui.Image> _loadCarImage(String assetPath, int width) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromAsset(
      String assetPath, int width) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Rotates the car image by [degrees] and returns it as a BitmapDescriptor.
  Future<BitmapDescriptor> _getRotatedCarBitmap(double degrees) async {
    debugPrint('🎨 [PASSENGER BITMAP] bearing=${degrees.toStringAsFixed(1)}°, offset=$_imageNorthOffsetDegrees°, carImage=${_carImage != null ? "loaded(${_carImage!.width}x${_carImage!.height})" : "NULL"}');
    if (_carImage == null) {
      debugPrint('🎨 [PASSENGER BITMAP] ❌ _carImage is null — returning default azure marker');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    final int w = _carImage!.width;
    final int h = _carImage!.height;
    final double diagonal = sqrt(w * w + h * h);
    final int canvasSize = diagonal.ceil();

    final double radians = ((degrees + _imageNorthOffsetDegrees) % 360) * pi / 180;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, canvasSize.toDouble(), canvasSize.toDouble()));

    final double cx = canvasSize / 2.0;
    final double cy = canvasSize / 2.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(radians);
    canvas.drawImage(
      _carImage!,
      Offset(-w / 2.0, -h / 2.0),
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();

    final ui.Picture picture = recorder.endRecording();
    final ui.Image rotatedImage = await picture.toImage(canvasSize, canvasSize);
    final ByteData? byteData =
        await rotatedImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
  }

  // ─── Bearing & snap-to-route ───────────────────────────────────────────────

  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final diffLng = (to.longitude - from.longitude) * pi / 180;

    final x = sin(diffLng) * cos(lat2);
    final y = cos(lat1) * sin(lat2) -
        sin(lat1) * cos(lat2) * cos(diffLng);

    return (atan2(x, y) * 180 / pi + 360) % 360;
  }

  /// Snaps [pos] to the nearest point on the stored route and returns its
  /// bearing toward the next route point.
  ({LatLng position, double bearing}) _snapToRoute(LatLng pos) {
    if (_currentRoutePoints.isEmpty) {
      return (position: pos, bearing: _currentBearing);
    }

    double minDist = double.infinity;
    LatLng closestPoint = pos;
    int closestIdx = _currentRouteSegmentIndex;

    final start = max(0, _currentRouteSegmentIndex - 2);
    for (int i = start; i < _currentRoutePoints.length; i++) {
      final d = _haversineKm(
            pos.latitude,
            pos.longitude,
            _currentRoutePoints[i].latitude,
            _currentRoutePoints[i].longitude,
          ) *
          1000; // metres
      if (d < minDist) {
        minDist = d;
        closestPoint = _currentRoutePoints[i];
        closestIdx = i;
      }
    }

    _currentRouteSegmentIndex = closestIdx;

    double bearing = _currentBearing;
    if (closestIdx < _currentRoutePoints.length - 1) {
      bearing = _calculateBearing(
          closestPoint, _currentRoutePoints[closestIdx + 1]);
    }
    _currentBearing = bearing;

    return (position: closestPoint, bearing: bearing);
  }

  /// Updates the driver marker with a rotated car icon at [position].
  Future<void> _updateDriverMarkerWithRotation(
      LatLng position, double bearing, String locationName) async {
    debugPrint('🚕 [PASSENGER MARKER] bearing=${bearing.toStringAsFixed(1)}°, pos=${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}, carImage=${_carImage != null ? "loaded" : "NULL"}');

    final BitmapDescriptor icon = await _getRotatedCarBitmap(bearing);

    debugPrint('🚕 [PASSENGER MARKER] icon.hashCode=${icon.hashCode}, markersBeforeUpdate=${markers.length}');

    markers = {
      ...markers.where((m) => m.markerId.value != 'driver_location'),
      Marker(
        markerId: const MarkerId('driver_location'),
        position: position,
        icon: icon,
        // The driver's app sends its own label; name the pin in this user's language.
        infoWindow: InfoWindow(title: AppLocalization.tr.driverLabel),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ),
    };

    debugPrint('🚕 [PASSENGER MARKER] ✅ markers updated, new size=${markers.length}');
  }

  // ─── Location permission & initial position ────────────────────────────────

  /// Subscribes to the device GPS so the passenger marker and the camera
  /// follow the user in real time (updates every 10 m of movement).
  void _startLiveLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.positionStream().listen(
      (position) {
        currentPosition = position;
        isLoading = false;
        _updateCurrentLocationMarker(position);
        update();

        // Don't fight the camera while a driver route is being framed.
        if (_followUserCamera) {
          followCameraTo(LatLng(position.latitude, position.longitude));
        }
      },
      onError: (Object error) {
        debugPrint('HomePageController: position stream failed — $error');
        _positionSubscription?.cancel();
        _positionSubscription = null;
      },
    );
  }

  void _updateCurrentLocationMarker(Position position) {
    // Position updates arrive from a stream, which can outlive the context.
    // A missing label must not cost us the marker and the camera move.
    final BuildContext? context = Get.context;
    final String label = context == null
        ? ''
        : AppLocalizations.of(context)?.yourLocationMarker ?? '';

    markers = {
      ...markers.where((m) => m.markerId.value != 'current_location'),
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: label),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };
  }

  Future<void> _getCurrentLocation() async {
    final Position? position = await LocationService.readPosition();

    isLoading = false;
    if (position == null) {
      // The live stream below is still the app's second chance at a fix.
      update();
      return;
    }

    currentPosition = position;
    _updateCurrentLocationMarker(position);
    update();

    moveCameraTo(LatLng(position.latitude, position.longitude));
  }

  // ─── Driver location tracking + polyline ──────────────────────────────────

  void startDriverLocationTracking(LatLng pickupLocation) {
    _lastFetchedDriverLocation = null;
    _followUserCamera = false;
    _resetRouteState();

    debugPrint('🟢 [POLYLINE DEBUG] startDriverLocationTracking called');
    debugPrint('🟢 [POLYLINE DEBUG] pickupLocation = ${pickupLocation.latitude}, ${pickupLocation.longitude}');

    // Add pickup pin marker
    _addPinMarker('pickup_location', pickupLocation, AppLocalization.tr.pickupLabel);

    SocketIoService.to.onUpdateLocation((data) async {
      if (data == null || data is! Map<String, dynamic>) return;

      final lat = (data['latitude'] as num).toDouble();
      final lng = (data['longitude'] as num).toDouble();
      final locationName = data['locationName'] as String? ?? AppLocalization.tr.driverLabel;
      final driverLatLng = LatLng(lat, lng);

      debugPrint('🟡 [SOCKET] update-location → lat=$lat, lng=$lng');
      debugPrint('🟡 [SOCKET] routePoints=${_currentRoutePoints.length}, prevDriverPos=$_previousDriverPosition');
      debugPrint('🟡 [POLYLINE DEBUG] update-location received → driver lat=$lat, lng=$lng');
      debugPrint('🟡 [POLYLINE DEBUG] polyline origin (driver) = $lat, $lng');
      debugPrint('🟡 [POLYLINE DEBUG] polyline destination (pickup) = ${pickupLocation.latitude}, ${pickupLocation.longitude}');

      // Only re-fetch Directions API when driver has moved ≥ 50 m
      final shouldFetch = _lastFetchedDriverLocation == null ||
          _haversineKm(
                _lastFetchedDriverLocation!.latitude,
                _lastFetchedDriverLocation!.longitude,
                lat,
                lng,
              ) >=
              0.05;

      debugPrint('🟡 [POLYLINE DEBUG] shouldFetch=$shouldFetch (lastFetched=${_lastFetchedDriverLocation?.latitude}, ${_lastFetchedDriverLocation?.longitude})');

      if (shouldFetch) {
        _lastFetchedDriverLocation = driverLatLng;
        await _fetchAndDrawRoute(driverLatLng, pickupLocation);
      }

      // Snap to route for smooth bearing.
      // If route not yet loaded, fall back to movement direction bearing.
      final snapped = _snapToRoute(driverLatLng);
      double bearing = snapped.bearing;
      if (_currentRoutePoints.isEmpty && _previousDriverPosition != null) {
        bearing = _calculateBearing(_previousDriverPosition!, driverLatLng);
        _currentBearing = bearing;
      }
      _previousDriverPosition = driverLatLng;

      await _updateDriverMarkerWithRotation(snapped.position, bearing, locationName);
      update();

      // Animate camera to keep both driver and pickup in frame
      final bounds = LatLngBounds(
        southwest: LatLng(
          min(lat, pickupLocation.latitude) - 0.005,
          min(lng, pickupLocation.longitude) - 0.005,
        ),
        northeast: LatLng(
          max(lat, pickupLocation.latitude) + 0.005,
          max(lng, pickupLocation.longitude) + 0.005,
        ),
      );
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    });
  }

  // Switch polyline target from pickup → destination when ride begins
  void startRideToDestinationTracking(LatLng destination) {
    SocketIoService.to.offUpdateLocation();
    _lastFetchedDriverLocation = null;
    _followUserCamera = false;
    _resetRouteState();

    // Replace pickup pin with destination pin
    markers = Set<Marker>.from(
        markers.where((m) => m.markerId.value != 'pickup_location'));
    _addPinMarker('destination_location', destination, AppLocalization.tr.destinationLabel);

    SocketIoService.to.onUpdateLocation((data) async {
      if (data == null || data is! Map<String, dynamic>) return;

      final lat = (data['latitude'] as num).toDouble();
      final lng = (data['longitude'] as num).toDouble();
      final locationName = data['locationName'] as String? ?? AppLocalization.tr.driverLabel;
      final driverLatLng = LatLng(lat, lng);

      // Re-fetch route only when driver moves ≥ 50 m
      final shouldFetch = _lastFetchedDriverLocation == null ||
          _haversineKm(
                _lastFetchedDriverLocation!.latitude,
                _lastFetchedDriverLocation!.longitude,
                lat,
                lng,
              ) >=
              0.05;

      if (shouldFetch) {
        _lastFetchedDriverLocation = driverLatLng;
        await _fetchAndDrawRoute(driverLatLng, destination);
      }

      // Snap to route for smooth bearing.
      // If route not yet loaded, fall back to movement direction bearing.
      final snapped = _snapToRoute(driverLatLng);
      double bearing = snapped.bearing;
      if (_currentRoutePoints.isEmpty && _previousDriverPosition != null) {
        bearing = _calculateBearing(_previousDriverPosition!, driverLatLng);
        _currentBearing = bearing;
      }
      _previousDriverPosition = driverLatLng;

      await _updateDriverMarkerWithRotation(snapped.position, bearing, locationName);
      update();

      // Keep both driver and destination in frame
      final bounds = LatLngBounds(
        southwest: LatLng(
          min(lat, destination.latitude) - 0.005,
          min(lng, destination.longitude) - 0.005,
        ),
        northeast: LatLng(
          max(lat, destination.latitude) + 0.005,
          max(lng, destination.longitude) + 0.005,
        ),
      );
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    });
  }

  // ─── Destination 500 m radius circle ──────────────────────────────────────

  Future<void> showDestinationRadiusCircle(LatLng destination) async {
    circles = {
      Circle(
        circleId: const CircleId('destination_radius'),
        center: destination,
        radius: 500,
        fillColor: Colors.blue.withOpacity(0.15),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    };

    // Place a text label at the top edge of the circle (~500 m north)
    final labelIcon = await _createRadiusLabelBitmap('500m radius');
    const double offsetDeg = 0.0045; // ≈ 500 m in latitude degrees
    markers = {
      ...markers.where((m) => m.markerId.value != 'destination_radius_label'),
      Marker(
        markerId: const MarkerId('destination_radius_label'),
        position: LatLng(destination.latitude + offsetDeg, destination.longitude),
        icon: labelIcon,
        anchor: const Offset(0.5, 1.0),
        flat: true,
      ),
    };

    update();
  }

  void clearDestinationRadiusCircle() {
    circles = {};
    markers = Set<Marker>.from(
      markers.where((m) => m.markerId.value != 'destination_radius_label'),
    );
    update();
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

  // ─── Nearest-driver markers (shown while passenger is searching) ───────────

  void showNearestDriverMarkers(List<dynamic> drivers) {
    final newMarkers = <Marker>{};
    for (final raw in drivers) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['_id'] as String? ?? '';
      if (id.isEmpty) continue;

      // GeoJSON coordinates: [longitude, latitude]
      final coords =
          (raw['location']?['coordinates'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0];
      if (coords.length < 2) continue;

      final lat = coords[1];
      final lng = coords[0];
      final locationName = raw['locationName'] as String? ?? AppLocalization.tr.driverLabel;

      newMarkers.add(Marker(
        markerId: MarkerId('nearest_driver_$id'),
        position: LatLng(lat, lng),
        icon: _smallCarIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        // The driver's app sends its own label; name the pin in this user's language.
        infoWindow: InfoWindow(title: AppLocalization.tr.driverLabel),
        anchor: const Offset(0.5, 0.5),
        flat: true,
      ));
    }

    // Remove old nearest-driver markers, keep everything else
    markers = {
      ...markers.where((m) => !m.markerId.value.startsWith('nearest_driver_')),
      ...newMarkers,
    };
    update();
  }

  void clearNearestDriverMarkers() {
    markers = Set<Marker>.from(
      markers.where((m) => !m.markerId.value.startsWith('nearest_driver_')),
    );
    update();
  }

  void stopDriverLocationTracking() {
    SocketIoService.to.offUpdateLocation();
    _lastFetchedDriverLocation = null;
    _followUserCamera = true;
    _resetRouteState();
    polylines = {};
    circles = {};
    markers = Set<Marker>.from(
      markers.where((m) =>
          m.markerId.value != 'driver_location' &&
          m.markerId.value != 'pickup_location' &&
          m.markerId.value != 'destination_location' &&
          m.markerId.value != 'destination_radius_label'),
    );
    update();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _resetRouteState() {
    _currentRoutePoints = [];
    _currentRouteSegmentIndex = 0;
    _currentBearing = 0.0;
    _previousDriverPosition = null;
  }

  void _addPinMarker(String id, LatLng position, String title) {
    markers = {
      ...markers.where((m) => m.markerId.value != id),
      Marker(
        markerId: MarkerId(id),
        position: position,
        icon: _pinMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: title),
      ),
    };
  }

  Future<void> _fetchAndDrawRoute(LatLng origin, LatLng destination) async {
    debugPrint('🔶 [POLYLINE DEBUG] _fetchAndDrawRoute called');
    debugPrint('🔶 [POLYLINE DEBUG] origin (should be DRIVER) = ${origin.latitude}, ${origin.longitude}');
    debugPrint('🔶 [POLYLINE DEBUG] destination (should be PICKUP/DEST) = ${destination.latitude}, ${destination.longitude}');
    try {
      final data = await MapsService().directions(origin.latitude,
          origin.longitude, destination.latitude, destination.longitude);
      debugPrint('🔶 [POLYLINE DEBUG] Directions API status = ${data['status']}');

      if (data['status'] == 'OK') {
        final encoded =
            data['routes'][0]['overview_polyline']['points'] as String;
        final routePoints = _decodePolyline(encoded);

        // Store for snap-to-route bearing calculations
        _currentRoutePoints = routePoints;
        _currentRouteSegmentIndex = 0;

        polylines = {
          Polyline(
            polylineId: const PolylineId('driver_to_pickup'),
            points: routePoints,
            color: Colors.black,
            width: 5,
          ),
        };
      } else {
        _fallbackStraightLine(origin, destination);
      }
    } catch (_) {
      _fallbackStraightLine(origin, destination);
    }

    update();
  }

  void _fallbackStraightLine(LatLng origin, LatLng destination) {
    _currentRoutePoints = [origin, destination];
    polylines = {
      Polyline(
        polylineId: const PolylineId('driver_to_pickup'),
        points: [origin, destination],
        color: Colors.black,
        width: 5,
      ),
    };
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
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
      final int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _rideSnapshotWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    disposeMapController();
    SocketIoService.to.offIncompletedRide();

    super.onClose();
  }
}
