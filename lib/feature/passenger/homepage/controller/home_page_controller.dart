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
import 'package:ride_sharing/services/map_motion.dart';
import 'package:ride_sharing/services/car_marker_animator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/services/app_mode.dart';

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
  BitmapDescriptor? _pinMarkerIcon;
  BitmapDescriptor? _carIcon;

  // Every car on the map — the booked driver and nearby available ones —
  // glides between fixes through one animator. Rotation is the marker's own
  // `rotation`, so the icon is drawn once rather than on every fix.
  static const String _driverMarkerId = 'driver_location';
  static const String _nearbyMarkerPrefix = 'nearby_driver_';
  late final CarMarkerAnimator _cars = CarMarkerAnimator(onFrame: _renderCars);
  Timer? _coveredRenderRetry;

  // Route state for snap-to-route bearing
  List<LatLng> _currentRoutePoints = [];
  int _currentRouteSegmentIndex = 0;
  double _currentBearing = 0.0;

  // Tracks last position where Directions API was called — avoids redundant fetches
  LatLng? _lastFetchedDriverLocation;

  // The pickup or destination the booked driver is heading to; null when no
  // driver is being tracked.
  LatLng? _trackingTarget;
  String? _trackingPinId;
  bool get isTrackingDriver => _trackingTarget != null;

  // Keeps the driver in frame until the user pans the map themselves; the
  // recenter button turns it back on.
  bool followDriver = true;
  bool _hasFramedDriver = false;

  // Nearby available drivers, watched while no driver is booked.
  bool _watchingNearby = false;
  // Cars added only because a ride request went to them; live nearby cars
  // are never in here, so clearing the search leaves those on the map.
  final Set<String> _searchOnlyCars = {};
  LatLng? _nearbySubscribedAt;
  Timer? _nearbyStaleTimer;
  Worker? _connectionWorker;

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
    AppMode.set(driver: false);
    WidgetsBinding.instance.addObserver(this);
    // Deferred to the first frame so Get.context exists — the permission
    // dialogs below are localized and need a BuildContext.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMap());
    _setupIncompletedRideListener();
    _rideSnapshotWorker = ever<RideSnapshot?>(RideSessionController.to.ride,
        _applyRideSnapshot);
    _applyRideSnapshot(RideSessionController.to.ride.value);
    // A new connection has lost its rooms and, if the socket was replaced,
    // its listeners too.
    _connectionWorker = ever<bool>(SocketIoService.to.isConnected, (connected) {
      if (!connected) return;
      if (isTrackingDriver) _listenForDriverLocation();
      if (_watchingNearby) {
        _listenForNearbyDrivers();
        _nearbySubscribedAt = null;
        _startNearbyDrivers();
      }
    });
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
    _syncDriverTracking(snapshot);
    update();
  }

  /// Puts the map in the mode the ride calls for: the booked car while a
  /// driver is on the way or driving, otherwise every available car nearby.
  /// Also how tracking comes back after the app is reopened mid-ride.
  void _syncDriverTracking(RideSnapshot? snapshot) {
    final status = snapshot?.status;
    if (status == 'ACCEPTED' || status == 'ONGOING') {
      final place = snapshot!.data[status == 'ACCEPTED' ? 'pickUp' : 'destination'];
      final coords = place is Map ? place['coordinates'] : null;
      if (coords is List && coords.length >= 2) {
        // GeoJSON order: [longitude, latitude]
        final target = LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble());
        if (status == 'ACCEPTED') {
          startDriverLocationTracking(target);
        } else {
          startRideToDestinationTracking(target);
        }
      }
      return;
    }
    // No snapshot means the server has no current ride for this user — it
    // ended while the app was away.
    if (isTrackingDriver &&
        (status == null || status == 'CANCELLED' || status == 'COMPLETED' ||
            status == 'PAID')) {
      stopDriverLocationTracking();
    }
    if (!isTrackingDriver) _startNearbyDrivers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _cars.pause();
      return;
    }
    if (state != AppLifecycleState.resumed) return;
    _cars.resume();
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
      _carIcon = await _getBitmapDescriptorFromAsset(
        'assets/images/3D_car.png',
        _carImageSize,
      );
    } catch (_) {
      // Fallback to defaults if assets are missing
    }
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

  // ─── Car markers ───────────────────────────────────────────────────────────

  bool _isCarMarker(String id) =>
      id == _driverMarkerId || id.startsWith(_nearbyMarkerPrefix);

  /// Redraws every car where the animator says it is right now. Only the map
  /// rebuilds ('map' id), not the sheets and cards around it.
  void _renderCars() {
    // Another page is on top: nobody sees the map, so skip the marker work
    // and check back shortly to draw the cars where they belong by then.
    final context = scaffoldKey.currentContext;
    if (context != null && ModalRoute.of(context)?.isCurrent == false) {
      _coveredRenderRetry ??= Timer(const Duration(milliseconds: 500), () {
        _coveredRenderRetry = null;
        _renderCars();
      });
      return;
    }
    final cars = _cars.frames;
    final icon = _carIcon ??
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    markers = {
      ...markers.where((m) => !_isCarMarker(m.markerId.value)),
      for (final car in cars.entries)
        Marker(
          markerId: MarkerId(car.key),
          position: car.value.position,
          rotation: (car.value.bearing + _imageNorthOffsetDegrees) % 360,
          icon: icon,
          // The driver's app sends its own label; name the pin in this user's language.
          infoWindow: InfoWindow(title: AppLocalization.tr.driverLabel),
          anchor: const Offset(0.5, 0.5),
          flat: true,
          zIndexInt: car.key == _driverMarkerId ? 2 : 1,
        ),
    };
    update(['map']);
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
        _startNearbyDrivers();

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
    _startNearbyDrivers();

    moveCameraTo(LatLng(position.latitude, position.longitude));
  }

  // ─── Driver location tracking + polyline ──────────────────────────────────

  void startDriverLocationTracking(LatLng pickupLocation) => _trackAssignedDriver(
      pickupLocation, 'pickup_location', AppLocalization.tr.pickupLabel);

  // Switch polyline target from pickup → destination when ride begins
  void startRideToDestinationTracking(LatLng destination) {
    markers = Set<Marker>.from(
        markers.where((m) => m.markerId.value != 'pickup_location'));
    _trackAssignedDriver(
        destination, 'destination_location', AppLocalization.tr.destinationLabel);
  }

  void _trackAssignedDriver(LatLng target, String pinId, String pinLabel) {
    // The sheets and the ride snapshot can both ask for the same leg.
    if (_trackingTarget == target && _trackingPinId == pinId) return;

    _stopNearbyDrivers(clear: true);
    _lastFetchedDriverLocation = null;
    _followUserCamera = false;
    _resetRouteState();
    _trackingTarget = target;
    _trackingPinId = pinId;
    followDriver = true;
    _hasFramedDriver = false;

    _addPinMarker(pinId, target, pinLabel);
    update();
    _listenForDriverLocation();
  }

  void _listenForDriverLocation() {
    SocketIoService.to.offUpdateLocation();
    SocketIoService.to.onUpdateLocation((data) {
      if (data is Map) _onDriverFix(Map<String, dynamic>.from(data));
    });
  }

  Future<void> _onDriverFix(Map<String, dynamic> data) async {
    final target = _trackingTarget;
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    if (target == null || lat == null || lng == null) return;
    final fix = LatLng(lat, lng);

    // Only re-fetch Directions API when driver has moved ≥ 50 m
    if (_lastFetchedDriverLocation == null ||
        distanceMeters(_lastFetchedDriverLocation!, fix) >= 50) {
      _lastFetchedDriverLocation = fix;
      await _fetchAndDrawRoute(fix, target);
      // The leg may have changed (or ended) while directions were loading.
      if (_trackingTarget != target) return;
    }

    final previous = _cars.targetOf(_driverMarkerId);
    final heading = (data['heading'] as num?)?.toDouble();
    final speed = (data['speed'] as num?)?.toDouble() ?? 0;

    // On the route, ride along it; off it, trust the phone's heading while
    // moving, else the direction between the last two fixes.
    LatLng position = fix;
    double bearing = _currentBearing;
    final projection = projectOntoRoute(fix, _currentRoutePoints,
        fromIndex: _currentRouteSegmentIndex);
    if (projection != null && projection.offRouteMeters <= kMaxRouteSnapMeters) {
      position = projection.position;
      bearing = projection.bearing;
      _currentRouteSegmentIndex = projection.segmentIndex;
    } else if (heading != null && speed > 1) {
      bearing = heading;
    } else if (previous != null && distanceMeters(previous, fix) > 2) {
      bearing = bearingBetween(previous, fix);
    }
    _currentBearing = bearing;

    _cars.moveTo(_driverMarkerId, position, bearing,
        timestamp: (data['timestamp'] as num?)?.toInt(),
        animate: previous != null);
    await _keepDriverInView(fix, target);
  }

  /// Frames driver and target once, then only re-frames when the car is about
  /// to leave the screen — not on every fix, and never after the user has
  /// moved the map themselves.
  Future<void> _keepDriverInView(LatLng driver, LatLng target) async {
    final controller = mapController;
    if (!followDriver || controller == null) return;
    if (_hasFramedDriver) {
      try {
        final visible = await controller.getVisibleRegion();
        if (visible.contains(driver)) return;
      } catch (_) {
        // The map may be gone; the next fix will try again.
        return;
      }
    }
    _hasFramedDriver = true;
    _frameDriverAndTarget(driver, target);
  }

  void _frameDriverAndTarget(LatLng driver, LatLng target) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        min(driver.latitude, target.latitude) - 0.005,
        min(driver.longitude, target.longitude) - 0.005,
      ),
      northeast: LatLng(
        max(driver.latitude, target.latitude) + 0.005,
        max(driver.longitude, target.longitude) + 0.005,
      ),
    );
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  /// The user touched the map: stop pulling the camera back to the driver.
  void onUserMovedMap() {
    if (!isTrackingDriver || !followDriver) return;
    followDriver = false;
    update(['map']);
  }

  void recenterOnDriver() {
    final target = _trackingTarget;
    if (target == null) return;
    followDriver = true;
    _hasFramedDriver = true;
    _frameDriverAndTarget(_cars.targetOf(_driverMarkerId) ?? target, target);
    update(['map']);
  }

  // ─── Nearby available drivers (live, before a driver is booked) ──────────

  /// Watches the available cars around the user. Cheap to call on every fix:
  /// it only re-subscribes after the user has moved 1 km.
  Future<void> _startNearbyDrivers() async {
    final position = currentPosition;
    if (position == null || isTrackingDriver) return;
    final here = LatLng(position.latitude, position.longitude);
    if (_watchingNearby &&
        _nearbySubscribedAt != null &&
        distanceMeters(_nearbySubscribedAt!, here) < 1000) {
      return;
    }

    final socket = SocketIoService.to;
    if (!_watchingNearby) {
      _watchingNearby = true;
      _listenForNearbyDrivers();
      _nearbyStaleTimer ??= Timer.periodic(const Duration(seconds: 15), (_) {
        _cars.removeStale(const Duration(seconds: 60),
            where: (id) => id.startsWith(_nearbyMarkerPrefix));
      });
    }
    // Never ask while offline: a request on a dead socket makes the service
    // build a new one, dropping every other screen's listeners. The
    // reconnect worker subscribes as soon as the socket is back.
    if (!socket.isSocketReady) return;
    _nearbySubscribedAt = here;

    final drivers = await socket.subscribeNearbyDrivers(
        latitude: here.latitude, longitude: here.longitude);
    if (drivers == null) {
      // Not connected yet — the next fix or the reconnect retries.
      _nearbySubscribedAt = null;
      return;
    }
    if (!_watchingNearby) return;
    for (final raw in drivers) {
      if (raw is! Map) continue;
      final lat = (raw['latitude'] as num?)?.toDouble();
      final lng = (raw['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null || (lat == 0 && lng == 0)) continue;
      final id = '$_nearbyMarkerPrefix${raw['driverId']}';
      _searchOnlyCars.remove(id);
      if (_cars.contains(id)) continue;
      _cars.moveTo(id, LatLng(lat, lng),
          (raw['heading'] as num?)?.toDouble() ?? 0,
          animate: false);
    }
  }

  void _listenForNearbyDrivers() {
    SocketIoService.to
      ..onNearbyDriverLocation(_onNearbyDriverFix)
      ..onNearbyDriverRemoved((data) {
        if (data is Map) _cars.remove('$_nearbyMarkerPrefix${data['driverId']}');
      });
  }

  void _onNearbyDriverFix(dynamic data) {
    if (!_watchingNearby || data is! Map) return;
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return;
    final id = '$_nearbyMarkerPrefix${data['driverId']}';
    _searchOnlyCars.remove(id);
    final fix = LatLng(lat, lng);
    final previous = _cars.targetOf(id);
    final heading = (data['heading'] as num?)?.toDouble();
    final bearing = heading ??
        (previous != null && distanceMeters(previous, fix) > 2
            ? bearingBetween(previous, fix)
            : _cars.bearingOf(id) ?? 0);
    _cars.moveTo(id, fix, bearing,
        timestamp: (data['timestamp'] as num?)?.toInt(),
        animate: previous != null);
  }

  void _stopNearbyDrivers({bool clear = false}) {
    if (_watchingNearby) {
      _watchingNearby = false;
      _nearbySubscribedAt = null;
      _nearbyStaleTimer?.cancel();
      _nearbyStaleTimer = null;
      SocketIoService.to
        ..offNearbyDriverLocation()
        ..offNearbyDriverRemoved()
        ..unsubscribeNearbyDrivers();
    }
    if (clear) {
      _searchOnlyCars.clear();
      _cars.removeWhere((id) => id.startsWith(_nearbyMarkerPrefix));
    }
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

  /// The drivers a new request was sent to. They join the live nearby cars
  /// (same marker ids), so they keep moving while the user waits for offers.
  void showNearestDriverMarkers(List<dynamic> drivers) {
    for (final raw in drivers) {
      if (raw is! Map) continue;
      final id = raw['_id'] as String? ?? '';
      if (id.isEmpty) continue;

      // GeoJSON coordinates: [longitude, latitude]
      final coords =
          (raw['location']?['coordinates'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [0.0, 0.0];
      if (coords.length < 2) continue;

      final markerId = '$_nearbyMarkerPrefix$id';
      if (_cars.contains(markerId)) continue;
      _searchOnlyCars.add(markerId);
      _cars.moveTo(markerId, LatLng(coords[1], coords[0]),
          (raw['locationHeading'] as num?)?.toDouble() ?? 0,
          animate: false);
    }
  }

  /// Ends the search: drops the cars only it put on the map. Live nearby cars
  /// stay; booking a driver clears those through [_trackAssignedDriver].
  void clearNearestDriverMarkers() {
    final searchOnly = Set<String>.from(_searchOnlyCars);
    _searchOnlyCars.clear();
    _cars.removeWhere(searchOnly.contains);
  }

  void stopDriverLocationTracking() {
    SocketIoService.to.offUpdateLocation();
    _lastFetchedDriverLocation = null;
    _trackingTarget = null;
    _trackingPinId = null;
    followDriver = true;
    _followUserCamera = true;
    _resetRouteState();
    _cars.remove(_driverMarkerId);
    polylines = {};
    circles = {};
    markers = Set<Marker>.from(
      markers.where((m) =>
          m.markerId.value != 'pickup_location' &&
          m.markerId.value != 'destination_location' &&
          m.markerId.value != 'destination_radius_label'),
    );
    update();
    if (!rideRequestActive) _startNearbyDrivers();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _resetRouteState() {
    _currentRoutePoints = [];
    _currentRouteSegmentIndex = 0;
    _currentBearing = 0.0;
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

  // ──────────────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _rideSnapshotWorker?.dispose();
    _connectionWorker?.dispose();
    _stopNearbyDrivers();
    // The socket outlives this controller; its handler must not either.
    SocketIoService.to.offUpdateLocation();
    _trackingTarget = null;
    _cars.dispose();
    _coveredRenderRetry?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    disposeMapController();
    SocketIoService.to.offIncompletedRide();

    super.onClose();
  }
}
