import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/driver/homepage/controller/driver_home_controller.dart';
import 'package:ride_sharing/feature/driver/trip_flow/model/ride_request_model.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/feature/driver/trip_flow/view/trip_completion_payment_dialogs.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_horizontal_line.dart';
import 'package:ride_sharing/widgets/custom_vertical_line.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

// import your app colors here
// import '../../../../app/message_utils/app_colors.dart';

// Mock colors - replace with your actual AppColors


// Trip model
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
      pickupTime: 'Now',
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
  bidding,
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
  final RxDouble bidAmount = 0.0.obs;
  final TextEditingController bidController = TextEditingController();
  final Rx<RideRequestModel?> currentRideRequest = Rx<RideRequestModel?>(null);

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
                  pickupTime: 'Now',
                  pickupLocation: homeController.pickupName ?? 'Pickup Location',
                  dropoffLocation: homeController.destinationName ?? 'Destination',
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

  void _loadMockData() {
    pendingTrips.value = [
      TripRequest(
        id: '1',
        riderId: '',
        passengerName: 'Jane Cooper',
        passengerImage: 'assets/images/passenger1.jpg',
        rating: 4.9,
        pickupTime: '4:40 PM • 5 min',
        pickupLocation: '1011 Biggen St, Epping Glentworth 63936',
        dropoffLocation: '9971 W Anuy St, Lirica Plunguyekia 87861',
        fare: 100,
        distance: 3.3,
        vehicleType: 'Comfortable Sedans',
        note: 'Please call when you arrive at gate',
      ),
    ];
  }

  void selectTrip(TripRequest trip) {
    selectedTrip.value = trip;
    currentState.value = TripState.tripDetail;
  }

  void showBiddingScreen() {
    currentState.value = TripState.bidding;
  }

  Future<void> submitBid() async {
    if (bidAmount.value > 0 && currentRideRequest.value != null) {
      final rideId = currentRideRequest.value!.rideId;
      final amount = bidAmount.value.toStringAsFixed(0);

      _logger.i('Submitting bid - rideId: $rideId, amount: $amount');

      // Emit the new-bid socket event
      await SocketIoService.to.emitNewBid(
        rideId: rideId,
        amount: amount,
      );

      _logger.i('Bid submitted successfully');

      // Show success feedback
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.bidSubmitted,
        l10n.bidSentMessage('\$$amount'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Close the trip flow after submitting
      closeTripFlow();
    } else {
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(
        l10n.invalidBid,
        l10n.enterValidBidAmount,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
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
    await SocketIoService.to.emitDropOffRider();

    _logger.i('drop-off-rider event emitted successfully');

    // Show PaymentConfirmationDialog
    if (Get.context != null) {
      TripDialogs.showPaymentConfirmation(
        Get.context!,
        onPaymentReceived: () async {
          _logger.i('Payment received - emitting confirm-payment');
          final rideId = currentRideRequest.value?.rideId ?? '';
          await SocketIoService.to.emitConfirmPayment(rideId: rideId);
          _logger.i('confirm-payment emitted, navigating to driver home');
          _finishTripAndNavigateHome();
        },
        onDifferentAmount: () {
          _logger.i('Different amount - navigating to driver home');
          _finishTripAndNavigateHome();
        },
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
class DriverTripFlow extends StatelessWidget {
  final TripState? initialState;
  final VoidCallback? onDismiss;

  const DriverTripFlow({Key? key, this.initialState, this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DriverTripController>(
      init: DriverTripController(initialState: initialState, onDismiss: onDismiss),
      builder: (controller) {
        return Obx(() {
          switch (controller.currentState.value) {
            case TripState.pendingRequests:
              return const PendingTripsBottomSheet();
            case TripState.tripDetail:
              return const TripDetailBottomSheet();
            case TripState.bidding:
              return const BiddingBottomSheet();
            case TripState.tripTaken:
              return const TripTakenBottomSheet();
            case TripState.tripAccepted:
              return const TripAcceptedBottomSheet();
            case TripState.activeTrip:
              return const ActiveTripBottomSheet();
            case TripState.dropOffNavigation:
              return const DropOffNavigationBottomSheet();
            case TripState.dropOffArrived:
              return const DropOffArrivedBottomSheet();
          }
        });
      },
    );
  }
}

// 1. Pending Trips List (Image 1)
class PendingTripsBottomSheet extends StatelessWidget {
  const PendingTripsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] PendingTripsBottomSheet appeared');
    final controller = Get.find<DriverTripController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Expanded(
            child: Obx(() => ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.pendingTrips.length,
              itemBuilder: (context, index) {
                final trip = controller.pendingTrips[index];
                return TripRequestCard(
                  trip: trip,
                  onTap: () => controller.selectTrip(trip),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}

class TripRequestCard extends StatelessWidget {
  final TripRequest trip;
  final VoidCallback onTap;

  const TripRequestCard({
    Key? key,
    required this.trip,
    required this.onTap,
  }) : super(key: key);

  static final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
    //  height: MediaQuery.of(context).size.height ,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.passengerName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star,
                              size: 12.sp,
                              color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                            )),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            trip.rating.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.pickupTime,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tesxtColor,
                      ),
                    ),
                    Text(
                      trip.vehicleType,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Fare and distance
            Row(
              children: [
                Text(
                  l10n.fareLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.tesxtColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '\$${trip.fare.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${trip.distance} km',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Locations
            Container(
              decoration: BoxDecoration(
                color: Colors.white,                      // background (change if needed)
                borderRadius: BorderRadius.circular(16.r), // rounded corners
                border: Border.all(
                  color: Colors.grey.shade300,            // grey border
                  width: 1,
                ),
              ),
              child: Padding(
                padding:  EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Image.asset(AppImage.passenger),
                        SizedBox(height: 4.h),
                       CustomVerticalLine(height: 30.h, color: Colors.black),
                        SizedBox(height: 4.h),
                        Icon(Icons.location_on,color: AppColors.togglebuttonColor,)
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pickUp,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Text(
                            trip.pickupLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.dropOff,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Text(
                            trip.dropoffLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Ride Needs
            if (trip.rideNeeds.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: trip.rideNeeds.map((need) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    need.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],

            // Rider phone number — only shown when available
            if (trip.riderNumber.isNotEmpty) ...[
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: trip.riderNumber);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.phone, color: AppColors.primaryColor, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      trip.riderNumber,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Note
            if (trip.note.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.noteLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tesxtColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      trip.note,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      _logger.i('Accept button tapped - rideId: ${trip.id}');
                      await SocketIoService.to.emitNewOffer(rideId: trip.id);
                      _logger.i('new-offer emitted for rideId: ${trip.id}');
                      onTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.acceptButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Expanded(
                //   child: OutlinedButton(
                //     onPressed: onTap,
                //     style: OutlinedButton.styleFrom(
                //       padding: EdgeInsets.symmetric(vertical: 12.h),
                //       side: BorderSide(color: AppColors.grayShade100),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8.r),
                //       ),
                //     ),
                //     child: Text(
                //       l10n.bidButton,
                //       style: TextStyle(
                //         color: AppColors.appGreyColor,
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.find<DriverTripController>().closeTripFlow(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.cancelButton,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Trip Detail (Image 2)
class TripDetailBottomSheet extends StatelessWidget {
  const TripDetailBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] TripDetailBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height:MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: SizedBox(
              height: 3.h,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 10.sp,bottom: 16.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconWidget(
                    width: 40.0,
                    height: 40.0,
                    fontSize: 15.sp,
                  ),
                  IconButton(
                          onPressed: () => controller.searchAgain(),
                          icon: Icon(Icons.close),
                        ),
                ],
              ),
            ),
            // Close button
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: EdgeInsets.only(right: 16.w),
            //     child: IconButton(
            //       onPressed: () => controller.searchAgain(),
            //       icon: Icon(Icons.close),
            //     ),
            //   ),
            // ),

            // Passenger info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(

                          trip.passengerName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(
                                Icons.star,
                                size: 14.sp,
                                color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                              )),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${trip.rating})',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${trip.fare.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        '${trip.distance} km',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:  10.sp ),
              child: CustomHorizontalLine(
                thickness: 2.sp,
                color: Colors.black38,
              ),
            ),
            SizedBox(height: 24.h),

            // Locations
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(

                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.pickUp,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.tesxtColor,
                              ),
                            ),
                            Text(
                              trip.pickupLocation,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.dropOff,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.tesxtColor,
                              ),
                            ),
                            Text(
                              trip.dropoffLocation,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:  10.sp ),
              child: CustomHorizontalLine(
                thickness: 2.sp,
                color: Colors.black38,
              ),
            ),
            SizedBox(height: 16.h),

            // Ride Needs
            if (trip.rideNeeds.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    l10n.rideRequirements,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.tesxtColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: trip.rideNeeds.map((need) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        need.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),

            // Passenger note
            if (trip.note.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.passengersNote,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        trip.note,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

           // const Spacer(),
            SizedBox(height: 16.h,),
            // Action buttons
            Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 50.h,
                  //   child: OutlinedButton(
                  //     onPressed: () => controller.showBiddingScreen(),
                  //     style: OutlinedButton.styleFrom(
                  //     //  padding: EdgeInsets.symmetric(vertical: 20.h), // increased height
                  //       side: BorderSide(color: AppColors.grayShade100, width: 2),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(24.r),
                  //       ),
                  //     ),
                  //     child: Text(
                  //       l10n.bidButton,
                  //       style: TextStyle(
                  //         color: AppColors.grayShade100,
                  //         fontSize: 18.sp, // increased size
                  //         fontWeight: FontWeight.w700,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),

            ),
          ]))
          ) ],
      ),
    );
  }
}

// 3. Bidding Screen (Image 3)
class BiddingBottomSheet extends StatelessWidget {
  const BiddingBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] BiddingBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Close button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: IconButton(
                onPressed: () => controller.searchAgain(),
                icon: Icon(Icons.close),
              ),
            ),
          ),

          // Passenger info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.passengerName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (i) => Icon(
                              Icons.star,
                              size: 14.sp,
                              color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                            )),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(${trip.rating})',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${trip.fare.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      '${trip.distance} km',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal:  10.sp ),
            child: CustomHorizontalLine(
              thickness: 2.sp,
              color: Colors.black38,
            ),
          ),
          // Locations
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Image.asset(AppImage.passenger),
                        SizedBox(height: 4.h),
                        CustomVerticalLine(height: 60.h, color: Colors.black),
                       // SizedBox(height: 4.h),

                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pickUp,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Text(
                            trip.pickupLocation,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.location_on,color: AppColors.togglebuttonColor,),
                        SizedBox(height: 4.h),

                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dropOff,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Text(
                            trip.dropoffLocation,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal:  10.sp ),
            child: CustomHorizontalLine(
              thickness: 2.sp,
              color: Colors.black38,
            ),
          ),
          // Bid price input
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.putYourOfferPrice,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tesxtColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w,),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[200]!

                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: TextField(
                          controller: controller.bidController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.tesxtColor,
                          ),
                          decoration: InputDecoration(
                            hintText: '60',
                            hintStyle: TextStyle(
                              color: Colors.grey[200]!
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            controller.bidAmount.value = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        //  const Spacer(),

          // Submit button
          // Padding(
          //   padding: EdgeInsets.all(16.w),
          //   child: SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       onPressed: () => controller.submitBid(),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: AppColors.primaryColor,
          //         padding: EdgeInsets.symmetric(vertical: 16.h),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8.r),
          //         ),
          //       ),
          //       child: Text(
          //         l10n.submitButton,
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 16.sp,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// 4. Trip Taken by Another Driver (Image 4)
class TripTakenBottomSheet extends StatelessWidget {
  const TripTakenBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] TripTakenBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 24.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Success icon
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
              size: 40.sp,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            AppLocalization.tr.rideAcceptedTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.tesxtColor,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            AppLocalization.tr.navigateToPickupMessage,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 24.h),

          // Go to map button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Close bottom sheet and navigate to map with TripAcceptedBottomSheet
                 // Get.back();
                  controller.goToMapWithPickupRoute();
                },
                icon: Icon(Icons.map, color: Colors.white),
                label: Text(
                  l10n.goToMap,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Trip Accepted - Pickup Location (Image 5)
class TripAcceptedBottomSheet extends StatelessWidget {
  const TripAcceptedBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] TripAcceptedBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value;

    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.pickupLocation,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tesxtColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on,color: AppColors.togglebuttonColor,) ,
                      Text(
                        "${AppLocalization.tr.iWillPickYouUpLabel} ",
                     //   trip.pickupLocation,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () => controller.confirmPickup(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                       // padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        l10n.confirmPickup,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// 6. Active Trip with Navigation (Image 6)
class ActiveTripBottomSheet extends StatelessWidget {
  const ActiveTripBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] ActiveTripBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Navigation banner

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(0),
          ),
          margin: EdgeInsets.symmetric(vertical: 75.sp),
          child: Row(
            children: [
              Icon(
                Icons.navigation,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                '200 m    Turn right at block b, road no 18',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Bottom sheet
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Trip status
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.grayShade100,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    AppLocalization.tr.onATripLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.tesxtColor,
                    ),
                  ),
                ),
              ),


              SizedBox(height: 16.h),

              // Passenger info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.passengerName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tesxtColor,
                            ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  Icons.star,
                                  size: 14.sp,
                                  color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                                )),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '(${trip.rating})',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${trip.fare.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          '${trip.distance} km',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal:  16.sp),
              child: CustomHorizontalLine(thickness: 2,color: AppColors.grayShade100,),
            ),
              SizedBox(height: 24.h),

              // Trip details
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.pickUp,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.dropOff,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            // 'Block B, Banasree, Dhaka.', // static placeholder
                            trip.pickupLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            // 'Dhanmondi, Dhaka', // static placeholder
                            trip.dropoffLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Passenger note
              if (trip.note.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.passengersNote,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.tesxtColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          trip.note,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 24.h),

              // Accept offer button
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.startDropOff(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      l10n.acceptOffer,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DropOffNavigationBottomSheet extends StatelessWidget {
  const DropOffNavigationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] DropOffNavigationBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.r)),
      ),
      child: Padding(
        padding:  EdgeInsets.all(16.sp),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          SizedBox(height: 10.h,),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // Passenger info
                    // Passenger info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.passengerName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tesxtColor,
                                ),
                              ),
                             // SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      Icons.star,
                                      size: 12.sp,
                                      color: i < trip.rating.floor() ? Colors.amber : Colors.grey[300],
                                    )),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    // '5.0', // static placeholder
                                    trip.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                   // SizedBox(height: 16.h),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: 16.h),

                    // Trip info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.pickUp,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Text(
                                trip.pickupLocation,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.dropOff,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                trip.dropoffLocation,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Time, Distance, Fare
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'EST',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '6 min', // TODO: wire to real-time navigation ETA
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                l10n.distanceLabel,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                // '3.3 km', // static placeholder
                                '${trip.distance} km',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                l10n.fareLabel,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                // '\$ 24', // static placeholder
                                '\$${trip.fare.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.tesxtColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Complete Trip Button - emits drop-off-rider and shows payment dialog
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal:  16.sp),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () => controller.completeTrip(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenShade300,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                          ),
                          child: Text(
                            l10n.dropOffButton,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    CustomHorizontalLine(thickness: 2,),
                    SizedBox(height: 20.h),
                    // Navigation directions
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        NavigationStep(
                          icon: Icons.straight,
                          instruction: 'Head west on Road No. 3',
                          distance: '240 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_left,
                          instruction: 'Turn left onto Ave 3',
                          distance: '80 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right onto Road No. 5',
                          distance: '400 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_left,
                          instruction: 'Turn left',
                          distance: '110 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right at Titas Gas Rd',
                          distance: '160 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_left,
                          instruction: 'Turn left',
                          distance: '130 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right at Rampura',
                          distance: '160 m',
                        ),
                        NavigationStep(
                          icon: Icons.turn_right,
                          instruction: 'Turn right',
                          distance: '400 m',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 8. Drop-off Arrived with Navigation Banner (Image 2)
class DropOffArrivedBottomSheet extends StatelessWidget {
  const DropOffArrivedBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('🚗 [BottomSheet] DropOffArrivedBottomSheet appeared');
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DriverTripController>();
    final homeController = Get.find<DriverHomeScreenController>();
    final trip = controller.selectedTrip.value ??
        (controller.pendingTrips.isNotEmpty ? controller.pendingTrips.first : null);

    if (trip == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      child: Stack(
        children: [
          // Navigation banner at top (with some top margin)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: EdgeInsets.only(top: 70.w), // Adjust as needed
              child: Row(
                children: [
                  Icon(
                    Icons.navigation,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() {
                      final distance = homeController.currentStepDistance.value;
                      final instruction = homeController.currentStepInstruction.value;
                      final text = distance.isNotEmpty
                          ? '$distance    $instruction'
                          : instruction;
                      return Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet anchored to the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          // Passenger info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20.r,
                                backgroundImage: trip.passengerImageUrl.isNotEmpty
                      ? NetworkImage(trip.passengerImageUrl) as ImageProvider
                      : AssetImage(trip.passengerImage), // 'assets/images/passenger1.jpg'
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  trip.passengerName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tesxtColor,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  Icons.star,
                                  size: 12.sp,
                                  color: i < trip.rating.floor()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                )),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                // '5.0', // static placeholder
                                trip.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Divider(color: Colors.grey[300]),
                          SizedBox(height: 16.h),

                          // Trip info
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.pickUp,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      trip.pickupLocation,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.dropOff,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      trip.dropoffLocation,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Time, Distance, Fare
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'EST',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '6 min', // TODO: wire to real-time navigation ETA
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.distanceLabel,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      // '3.3 km', // static placeholder
                                      '${trip.distance} km',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.fareLabel,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      // '\$ 24', // static placeholder
                                      '\$${trip.fare.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColors.tesxtColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Navigate to Destination Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => controller.startDropOff(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                l10n.dropOffButton,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation step widget
class NavigationStep extends StatelessWidget {
  final IconData icon;
  final String instruction;
  final String distance;

  const NavigationStep({
    Key? key,
    required this.icon,
    required this.instruction,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: AppColors.tesxtColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.tesxtColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomHorizontalLine(thickness: 2,),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}












