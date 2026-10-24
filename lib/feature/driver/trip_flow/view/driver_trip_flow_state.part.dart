part of 'driver_trip_flow.dart';

class TripRequest {
  final String id;
  final String riderId;
  final String passengerName;
  final String passengerImage;    // local asset fallback
  final String passengerImageUrl; // network URL from socket payload
  final double rating;
  final String pickupTime;
  final String pickupLocation;
  final String dropoffLocation;
  final double fare;
  final double distance;
  final String vehicleType;
  final String note;
  final List<String> rideNeeds;
  final String riderNumber;

  TripRequest({
    required this.id,
    required this.riderId,
    required this.passengerName,
    required this.passengerImage,
    this.passengerImageUrl = '',
    required this.rating,
    required this.pickupTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.fare,
    required this.distance,
    required this.vehicleType,
    required this.note,
    this.rideNeeds = const [],
    this.riderNumber = '',
  });

  // Factory constructor to create TripRequest from RideRequestModel
  factory TripRequest.fromRideRequest(RideRequestModel rideRequest) {
    return TripRequest(
      id: rideRequest.rideId,
      riderId: rideRequest.riderId,
      passengerName: rideRequest.rider.name,
      passengerImage: 'assets/images/passenger1.jpg', // local asset fallback
      passengerImageUrl: rideRequest.rider.profilePicture,
      rating: rideRequest.rider.rating,
      pickupTime: AppLocalization.tr.nowLabel,
      pickupLocation: rideRequest.pickUp.name,
      dropoffLocation: rideRequest.destination.name,
      fare: rideRequest.fare,
      distance: double.tryParse(rideRequest.distance) ?? 0.0,
      vehicleType: 'Standard',
      note: rideRequest.note,
      rideNeeds: rideRequest.rideNeeds,
      riderNumber: rideRequest.riderNumber,
    );
  }
}

// Trip states enum
enum TripState {
  pendingRequests,
  tripDetail,
  tripTaken,
  tripAccepted,
  activeTrip, dropOffArrived, dropOffNavigation,
}

// Driver trip controller
class DriverTripController extends GetxController {
  final TripState? initialState;
  final VoidCallback? onDismiss;

  DriverTripController({this.initialState, this.onDismiss});

  late final Rx<TripState> currentState;
  final RxList<TripRequest> pendingTrips = <TripRequest>[].obs;
  final Rx<TripRequest?> selectedTrip = Rx<TripRequest?>(null);
  final Rx<RideRequestModel?> currentRideRequest = Rx<RideRequestModel?>(null);
  Worker? _rideSnapshotWorker;

  // Ride accepted data
  final RxString acceptedRideId = ''.obs;
  final RxString acceptedRiderId = ''.obs;
  final RxBool isRideAccepted = false.obs;

  // Flags to prevent duplicate handling
  bool _isRidePickedUpHandled = false;

  final Logger _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    // Initialize state - use initialState if provided, otherwise pendingRequests
    currentState = (initialState ?? TripState.pendingRequests).obs;
    _loadRideRequestData();
    _setupRideAcceptedListener();
    _setupRidePickedUpListener();
    _rideSnapshotWorker = ever<RideSnapshot?>(RideSessionController.to.ride,
        _applyRideSnapshot);
    _applyRideSnapshot(RideSessionController.to.ride.value);
  }

  void _applyRideSnapshot(RideSnapshot? snapshot) {
    if (snapshot == null) return;
    if (snapshot.status == 'CANCELLED' || snapshot.status == 'PAID') {
      if (selectedTrip.value?.id == snapshot.rideId) searchAgain();
      return;
    }
    if (snapshot.driverId == null) return;
    final home = Get.find<DriverHomeScreenController>();
    final request = home.currentRideRequest.value;
    if (request != null && request.rideId == snapshot.rideId) {
      currentRideRequest.value = request;
      selectedTrip.value = TripRequest.fromRideRequest(request);
    }
    acceptedRideId.value = snapshot.rideId;
    acceptedRiderId.value = snapshot.riderId;
    isRideAccepted.value = true;
    if (snapshot.status == 'ACCEPTED' &&
        currentState.value != TripState.tripAccepted) {
      currentState.value = TripState.tripTaken;
    } else if (snapshot.status == 'ONGOING') {
      currentState.value = TripState.dropOffArrived;
    }
  }

  @override
  void onClose() {
    _rideSnapshotWorker?.dispose();
    super.onClose();
  }

  void _setupRideAcceptedListener() {
    // Listen for ride-accepted from DriverHomeScreenController
    try {
      final homeController = Get.find<DriverHomeScreenController>();
      ever(homeController.isRideAccepted, (bool isAccepted) {
        if (isAccepted) {
          _logger.i('Ride accepted detected in DriverTripController, changing state to tripTaken');

          // Set the accepted ride data
          acceptedRideId.value = homeController.acceptedRideId.value;
          acceptedRiderId.value = homeController.acceptedRiderId.value;
          isRideAccepted.value = true;

          // Ensure we have the trip selected
          if (selectedTrip.value == null && pendingTrips.isNotEmpty) {
            selectedTrip.value = pendingTrips.first;
          }

          // Change state to show TripTakenBottomSheet
          currentState.value = TripState.tripTaken;
        }
      });
    } catch (e) {
      _logger.e('Error setting up ride accepted listener: $e');
    }
  }

  void _setupRidePickedUpListener() {
    // Listen for ride-picked-up from DriverHomeScreenController
    try {
      final homeController = Get.find<DriverHomeScreenController>();
      ever(homeController.isRidePickedUp, (bool isPickedUp) {
        if (isPickedUp && !_isRidePickedUpHandled) {
          _isRidePickedUpHandled = true;
          _logger.i('Ride picked up detected in DriverTripController, changing state to dropOffArrived');
          _logger.i('Debug - selectedTrip: ${selectedTrip.value}, pendingTrips: ${pendingTrips.length}, currentRideRequest: ${currentRideRequest.value}, homeController.currentRideRequest: ${homeController.currentRideRequest.value}');

          // Ensure we have the trip selected
          if (selectedTrip.value == null) {
            if (pendingTrips.isNotEmpty) {
              selectedTrip.value = pendingTrips.first;
              _logger.i('Set selectedTrip from pendingTrips.first');
            } else {
              // Try to create trip from currentRideRequest
              final rideRequest = currentRideRequest.value ??
                  homeController.currentRideRequest.value;
              if (rideRequest != null) {
                selectedTrip.value = TripRequest.fromRideRequest(rideRequest);
                _logger.i('Created selectedTrip from rideRequest in _setupRidePickedUpListener');
              } else {
                // Fallback: create a default trip to avoid loading indicator
                _logger.w('No ride request available, creating default trip');
                selectedTrip.value = TripRequest(
                  id: 'default',
                  riderId: '',
                  passengerName: 'Rider',
                  passengerImage: 'assets/images/passenger1.jpg',
                  rating: 5.0,
                  pickupTime: AppLocalization.tr.nowLabel,
                  pickupLocation: homeController.pickupName ?? AppLocalization.tr.pickupLocation,
                  dropoffLocation: homeController.destinationName ?? AppLocalization.tr.destinationLabel,
                  fare: 0,
                  distance: 0,
                  vehicleType: 'Standard',
                  note: '',
                );
              }
            }
          }

          _logger.i('Final selectedTrip: ${selectedTrip.value?.id}');

          // Change state to show DropOffArrivedBottomSheet (commented out DropOffNavigationBottomSheet)
        //   currentState.value = TripState.dropOffNavigation;
          currentState.value = TripState.dropOffArrived;
          _logger.i('State set to: ${currentState.value}');

        }
      });
    } catch (e) {
      _logger.e('Error setting up ride picked up listener: $e');
    }
  }



  void _loadRideRequestData() {
    try {
      final homeController = Get.find<DriverHomeScreenController>();
      final rideRequest = homeController.currentRideRequest.value;

      if (rideRequest != null) {
        currentRideRequest.value = rideRequest;
        final tripRequest = TripRequest.fromRideRequest(rideRequest);
        pendingTrips.value = [tripRequest];

        // If initialState is tripTaken (ride accepted), set selectedTrip and keep tripTaken state
        if (initialState == TripState.tripTaken) {
          selectedTrip.value = tripRequest;
          _logger.i('Set selectedTrip for tripTaken state');
          // Don't change currentState - keep it as tripTaken
        } else {
          // Keep the pendingRequests state to show the same UI as mock data
          currentState.value = TripState.pendingRequests;
        }
      }
      // Don't load mock data - if no ride request, the list will be empty
    } catch (e) {
      // If controller not found, don't show anything
      _logger.e('Error loading ride request data: $e');
    }
  }

  void selectTrip(TripRequest trip) {
    selectedTrip.value = trip;
    currentState.value = TripState.tripDetail;
  }

  void acceptTrip() {
    currentState.value = TripState.tripAccepted;
  }

  Future<void> goToMapWithPickupRoute() async {
    _logger.i('Going to map with pickup route');

    try {
      final homeController = Get.find<DriverHomeScreenController>();

      // Get pickup location from local or home controller's ride request
      final rideRequest = currentRideRequest.value ?? homeController.currentRideRequest.value;

      if (rideRequest != null) {
        final pickupLocation = rideRequest.pickUp;
        _logger.i('Pickup location: ${pickupLocation.name}, lat: ${pickupLocation.latitude}, lng: ${pickupLocation.longitude}');

        // Route is already shown on map from _handleRideAccepted, just transition state
        _logger.i('Route already shown via ride-accepted handler, transitioning to tripAccepted state');
      } else {
        _logger.e('No ride request available');
      }
    } catch (e) {
      _logger.e('Error in goToMapWithPickupRoute: $e');
    }

    // Change state to tripAccepted to show the TripAcceptedBottomSheet
    currentState.value = TripState.tripAccepted;
  }

  void startTrip() {
    // Ensure selectedTrip is set before transitioning
    if (selectedTrip.value == null) {
      if (pendingTrips.isNotEmpty) {
        selectedTrip.value = pendingTrips.first;
      } else {
        // Try to create trip from currentRideRequest or homeController
        final rideRequest = currentRideRequest.value ??
            Get.find<DriverHomeScreenController>().currentRideRequest.value;
        if (rideRequest != null) {
          selectedTrip.value = TripRequest.fromRideRequest(rideRequest);
          _logger.i('Created selectedTrip from rideRequest in startTrip()');
        } else {
          _logger.e('Cannot start trip - no ride request data available');
        }
      }
    }
    currentState.value = TripState.activeTrip;
  }

  void startDropOff() {
    currentState.value = TripState.dropOffNavigation;
  }

  void arrivedAtDestination() {
    currentState.value = TripState.dropOffArrived;
  }

  Future<void> completeTrip() async {
    _logger.i('Completing trip - emitting drop-off-rider socket event');

    // Emit drop-off-rider socket event
    final completed = await SocketIoService.to.emitDropOffRider();
    if (!completed) return;

    _logger.i('drop-off-rider event emitted successfully');

    // Completion is confirmed by the ride ack. Payment remains server-owned.
    if (Get.context != null) {
      TripDialogs.showTripCompletion(
        Get.context!,
        onBackToHome: _finishTripAndNavigateHome,
      );
    } else {
      // Fallback if context is not available
      _finishTripAndNavigateHome();
    }
  }

  void _finishTripAndNavigateHome() {
    // Close dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Clear ride states in home controller
    try {
      final homeController = Get.find<DriverHomeScreenController>();
      homeController.clearRidePickedUp();
      homeController.clearRideAccepted();
      homeController.clearRideRequest();
    } catch (e) {
      _logger.e('Error clearing ride states: $e');
    }

    // Reset flags for next trip
    _isRidePickedUpHandled = false;

    // Close the trip flow bottom sheet and go back to driver home
    currentState.value = TripState.pendingRequests;
    selectedTrip.value = null;

    // Dismiss the trip flow
    onDismiss?.call();
  }

  void searchAgain() {
    currentState.value = TripState.pendingRequests;
    selectedTrip.value = null;
  }

  void closeTripFlow() {
    onDismiss?.call();
  }

  Future<void> confirmPickup() async {
    _logger.i('Confirming pickup - emitting pickup-rider socket event');

    final success = await SocketIoService.to.emitPickupRider();

    _logger.i('pickup-rider ack result - success: $success');

    if (!success) {
      _logger.e('pickup-rider ack returned failure - not transitioning state');
      return;
    }

    try {
      final homeController = Get.find<DriverHomeScreenController>();

      // Stop pickup navigation (clears old polyline + pickup marker)
      homeController.stopNavigation();
      _logger.i('Stopped pickup navigation');

      // Immediately show route from current location to destination
      final rideRequest = currentRideRequest.value ?? homeController.currentRideRequest.value;
      if (rideRequest != null) {
        final destination = rideRequest.destination;
        _logger.i('Showing route to destination: ${destination.name} [${destination.latitude}, ${destination.longitude}]');
        await homeController.showRouteToDestination(
          destinationLat: destination.latitude,
          destinationLng: destination.longitude,
          destinationName: destination.name,
        );
        _logger.i('Destination route shown successfully');
      } else {
        _logger.e('No ride request found - cannot show destination route');
      }
    } catch (e) {
      _logger.e('Error showing destination route after pickup: $e');
    }

    // Ack success - remove TripAcceptedBottomSheet and show DropOffArrivedBottomSheet
    _logger.i('Transitioning to DropOffArrivedBottomSheet');
    currentState.value = TripState.dropOffArrived;
  }


}

// Main trip flow widget
