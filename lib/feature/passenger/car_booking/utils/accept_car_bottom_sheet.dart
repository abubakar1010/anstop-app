import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/controller/pick_up_location_controller.dart';
import 'package:ride_sharing/feature/passenger/homepage/controller/home_page_controller.dart';
import 'package:ride_sharing/widgets/custom_button.dart';
import 'package:ride_sharing/widgets/logo.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

import 'booking_car_bottomsheet.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

// Model for car information from driver
class CarInformation {
  final String id;
  final String brand;
  final String model;
  final String yearOfManufacture;
  final String? licensePlateNumber;
  final String? licensePlatePicture;

  CarInformation({
    required this.id,
    required this.brand,
    required this.model,
    required this.yearOfManufacture,
    this.licensePlateNumber,
    this.licensePlatePicture,
  });

  factory CarInformation.fromJson(Map<String, dynamic> json) {
    final licensePlate = json['licensePlate'] as Map<String, dynamic>?;

    return CarInformation(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      yearOfManufacture: json['yearOfManufacture'] ?? '',
      licensePlateNumber: licensePlate?['number'],
      licensePlatePicture: licensePlate?['picture'],
    );
  }
}

class NearbyDriver {
  final String id;
  final String name;
  final String email;
  final String locationName;
  final double distance;
  final List<double> coordinates;
  final String? profilePicture;
  final double rating;
  final int totalReviews;
  final CarInformation? carInformation;
  String? bidAmount; // Dynamic bid amount from driver

  NearbyDriver({
    required this.id,
    required this.name,
    this.email = '',
    this.locationName = '',
    this.distance = 0.0,
    this.coordinates = const [0.0, 0.0],
    this.profilePicture,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.carInformation,
    this.bidAmount,
  });

  factory NearbyDriver.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final coords = location?['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final carInfo = json['carInformation'] as Map<String, dynamic>?;
    final first = json['firstName'] ?? json['name'] ?? '';
    final last = json['lastName'] ?? '';

    return NearbyDriver(
      id: json['_id'] ?? '',
      name: '$first $last'.trim(),
      email: json['email'] ?? '',
      locationName: json['locationName'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      coordinates: coords.map((e) => (e as num).toDouble()).toList(),
      profilePicture: json['profilePicture'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      carInformation: carInfo != null ? CarInformation.fromJson(carInfo) : null,
    );
  }
}

// Model for bid data from socket (updated structure with driver object)
class BidData {
  final String rideId;
  final String amount;
  final String driverId;
  final String driverName;
  final String? profilePicture;
  final double rating;
  final int totalReviews;
  final CarInformation? carInformation;

  BidData({
    required this.rideId,
    required this.amount,
    required this.driverId,
    required this.driverName,
    this.profilePicture,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.carInformation,
  });

  factory BidData.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final carInfo = driver?['carInformation'] as Map<String, dynamic>?;
    final first = driver?['firstName'] ?? driver?['name'] ?? '';
    final last = driver?['lastName'] ?? '';

    return BidData(
      rideId: json['rideId'] ?? '',
      // Server sends raw floats (e.g. 5.2174999999999); show cents only.
      amount: num.tryParse('${json['amount']}')?.toStringAsFixed(2) ?? '0',
      driverId: driver?['_id'] ?? '',
      driverName: '$first $last'.trim(),
      profilePicture: driver?['profilePicture'],
      rating: (driver?['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (driver?['totalReviews'] as num?)?.toInt() ?? 0,
      carInformation: carInfo != null ? CarInformation.fromJson(carInfo) : null,
    );
  }
}

class AcceptCarBottomSheet extends StatefulWidget {
  final String pickUpAddress;
  final String destinationAddress;
  final String tripDistance; // Distance of the trip (e.g., "7.3" km)
  final List<dynamic>? initialDriversData;

  const AcceptCarBottomSheet({
    Key? key,
    required this.pickUpAddress,
    required this.destinationAddress,
    this.tripDistance = '',
    this.initialDriversData,
  }) : super(key: key);

  @override
  _AcceptCarBottomSheetState createState() => _AcceptCarBottomSheetState();
}

class _AcceptCarBottomSheetState extends State<AcceptCarBottomSheet> {
  List<NearbyDriver> nearbyDrivers = [];
  Map<String, String> driverBids = {}; // Map of driverId -> bidAmount
  Map<String, String> driverRideIds = {}; // Map of driverId -> rideId
  bool isLoading = true;
  bool isAccepting = false; // Loading state when accepting a bid
  String? acceptingDriverId; // Track which driver's bid is being accepted
  NearbyDriver? acceptedDriver; // Store the accepted driver's data
  String? acceptedBidAmount; // Store the accepted bid amount
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initDriversData();
    _initSocketAndListen();
    _initNewOfferListener();
    _initRideAcceptedListener();
    _startDriverPolylineTracking();
  }

  void _startDriverPolylineTracking() {
    try {
      final pickUpController = Get.find<PickUpLocationController>();
      final lat = double.tryParse(pickUpController.pickUpLatitudeController.text) ?? 0.0;
      final lng = double.tryParse(pickUpController.pickUpLongitudeController.text) ?? 0.0;
      debugPrint('🔵 [POLYLINE DEBUG] _startDriverPolylineTracking called');
      debugPrint('🔵 [POLYLINE DEBUG] pickUpLatitudeController.text = "${pickUpController.pickUpLatitudeController.text}"');
      debugPrint('🔵 [POLYLINE DEBUG] pickUpLongitudeController.text = "${pickUpController.pickUpLongitudeController.text}"');
      debugPrint('🔵 [POLYLINE DEBUG] parsed pickup → lat=$lat, lng=$lng');
      if (lat == 0.0 && lng == 0.0) {
        debugPrint('🔴 [POLYLINE DEBUG] pickup coords are 0,0 — tracking NOT started');
        return;
      }
      Get.find<HomePageController>().startDriverLocationTracking(LatLng(lat, lng));
      _logger.i('Driver polyline tracking started — pickup: $lat, $lng');
    } catch (e) {
      _logger.e('Failed to start driver polyline tracking: $e');
    }
  }

  void _initDriversData() {
    // If initial data is provided, use it immediately
    if (widget.initialDriversData != null && widget.initialDriversData!.isNotEmpty) {
      _logger. i('Using initial drivers data: ${widget.initialDriversData!.length} drivers');
      nearbyDrivers = widget.initialDriversData!
          .map((driverJson) => NearbyDriver.fromJson(driverJson as Map<String, dynamic>))
          .toList();
      isLoading = false;
      _logger.i('Initialized with ${nearbyDrivers.length} drivers');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<HomePageController>().showNearestDriverMarkers(widget.initialDriversData!);
      });
    }
  }

  Future<void> _initSocketAndListen() async {
    final socketService = SocketIoService.to;

    _logger.i('Current socket status - isConnected: ${socketService.isConnected.value}, isSocketReady: ${socketService.isSocketReady}');

    // Ensure socket is connected
    if (!socketService.isConnected.value) {
      _logger.i('Socket not connected, connecting...');
      await socketService.connect();

      // Wait a bit for connection to establish
      await Future.delayed(const Duration(milliseconds: 500));
      _logger.i('After connect - isConnected: ${socketService.isConnected.value}, isSocketReady: ${socketService.isSocketReady}');
    }

    _logger.i('Setting up listener for nearest-drivers event (for future updates)');

    // Use the dedicated method for nearest-drivers (for future updates)
    socketService.onNearestDrivers((data) {
      _logger.i('Received nearest-drivers event in AcceptCarBottomSheet: $data');

      if (data != null) {
        List<dynamic> driversList;

        // Handle both List and other formats
        if (data is List) {
          driversList = data;
        } else if (data is Map && data['data'] is List) {
          driversList = data['data'] as List;
        } else {
          _logger.e('Unexpected data format: ${data.runtimeType}');
          return;
        }

        if (mounted) {
          setState(() {
            nearbyDrivers = driversList
                .map((driverJson) => NearbyDriver.fromJson(driverJson as Map<String, dynamic>))
                .toList();
            isLoading = false;
          });
          _logger.i('Updated drivers list: ${nearbyDrivers.length} drivers');
          Get.find<HomePageController>().showNearestDriverMarkers(driversList);
        }
      }
    });
  }

  Future<void> _initNewOfferListener() async {
    final socketService = SocketIoService.to;

    if (!socketService.isConnected.value) {
      _logger.i('Socket not connected for new-offer, connecting...');
      await socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _logger.i('Setting up listener for new-offer event');

    socketService.onNewOffer((data) {
      _logger.i('Received new-offer event in AcceptCarBottomSheet: $data');

      if (data != null && data is Map<String, dynamic>) {
        final offerData = BidData.fromJson(data);
        _logger.i('Parsed offer - driverId: ${offerData.driverId}, name: ${offerData.driverName}, amount: ${offerData.amount}');

        if (mounted) {
          setState(() {
            // Store the offer amount and rideId for this driver
            driverBids[offerData.driverId] = offerData.amount;
            driverRideIds[offerData.driverId] = offerData.rideId;

            // Check if driver already exists in the list
            bool driverExists = false;
            for (int i = 0; i < nearbyDrivers.length; i++) {
              if (nearbyDrivers[i].id == offerData.driverId) {
                nearbyDrivers[i] = NearbyDriver(
                  id: offerData.driverId,
                  name: offerData.driverName,
                  email: nearbyDrivers[i].email,
                  locationName: nearbyDrivers[i].locationName,
                  distance: nearbyDrivers[i].distance,
                  coordinates: nearbyDrivers[i].coordinates,
                  profilePicture: offerData.profilePicture ?? nearbyDrivers[i].profilePicture,
                  rating: offerData.rating > 0 ? offerData.rating : nearbyDrivers[i].rating,
                  totalReviews: offerData.totalReviews > 0 ? offerData.totalReviews : nearbyDrivers[i].totalReviews,
                  carInformation: offerData.carInformation ?? nearbyDrivers[i].carInformation,
                  bidAmount: offerData.amount,
                );
                driverExists = true;
                break;
              }
            }

            // If driver not in list yet, add them
            if (!driverExists) {
              nearbyDrivers.add(NearbyDriver(
                id: offerData.driverId,
                name: offerData.driverName,
                profilePicture: offerData.profilePicture,
                rating: offerData.rating,
                totalReviews: offerData.totalReviews,
                carInformation: offerData.carInformation,
                bidAmount: offerData.amount,
              ));
              _logger.i('Added new driver from offer: ${offerData.driverName}');
            }

            isLoading = false;
          });
          _logger.i('Stored offer for driver ${offerData.driverId}: €${offerData.amount}, rideId: ${offerData.rideId}');
        }
      }
    });
  }

  Future<void> _initRideAcceptedListener() async {
    final socketService = SocketIoService.to;

    // Ensure socket is connected before setting up listener
    if (!socketService.isConnected.value) {
      _logger.i('Socket not connected for ride-accepted, connecting...');
      await socketService.connect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _logger.i('Setting up listener for ride-accepted event');

    // Listen for ride-accepted response from server (sent after passenger accepts bid)
    socketService.onRideAccepted((data) {
      _logger.i('Received ride-accepted event in AcceptCarBottomSheet: $data');

      if (mounted && acceptedDriver != null) {
        Get.find<HomePageController>().showPassengerSheet(
          (_) => BookingCarsBottomSheet(
            rideId: driverRideIds[acceptedDriver!.id] ?? '',
            driverId: acceptedDriver!.id,
            driverName: acceptedDriver!.name,
            driverProfilePicture: acceptedDriver!.profilePicture,
            driverRating: acceptedDriver!.rating,
            driverTotalReviews: acceptedDriver!.totalReviews,
            carBrand: acceptedDriver!.carInformation?.brand ?? '',
            carModel: acceptedDriver!.carInformation?.model ?? '',
            licensePlateNumber: acceptedDriver!.carInformation?.licensePlateNumber ?? '',
            licensePlatePicture: acceptedDriver!.carInformation?.licensePlatePicture,
            bidAmount: acceptedBidAmount ?? '',
            tripDistance: widget.tripDistance,
            pickUpAddress: widget.pickUpAddress,
            destinationAddress: widget.destinationAddress,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logger.i('Disposing AcceptCarBottomSheet, removing socket listeners');
    SocketIoService.to.offNearestDrivers();
    SocketIoService.to.offNewOffer();
    SocketIoService.to.offRideAccepted();
    // Deferred: update() can't rebuild GetBuilders while the tree is being
    // torn down, so clearing here directly throws and leaves the markers up.
    final homeController = Get.find<HomePageController>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => homeController.clearNearestDriverMarkers(),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      width: double.infinity,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          Expanded(child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Header Row with Logo and Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconWidget(
                width: 40.w,
                height: 40.h,
                fontSize: 15.sp,
              ),
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.greenShade50,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  onPressed: () {
                    Get.find<HomePageController>().closeCurrentSheet();
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 12.sp),

          // Pickup Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppImage.greetings),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  widget.pickUpAddress.isNotEmpty
                      ? widget.pickUpAddress
                      : l10n.pickupLocation,
                  style: TextStyle(fontSize: 14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Vertical line connector
          Padding(
            padding: EdgeInsets.only(left: 10.sp),
            child: Container(
              height: 20.h,
              width: 2,
              color: Colors.black,
            ),
          ),

          // Destination Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: AppColors.primaryColor),
              SizedBox(width: 8.sp),
              Expanded(
                child: Text(
                  widget.destinationAddress.isNotEmpty
                      ? widget.destinationAddress
                      : l10n.destination,
                  style: TextStyle(fontSize: 14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          Divider(
            color: AppColors.grayShade100,
            thickness: 1,
          ),

          SizedBox(height: 8.sp),

          // Drivers List
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          l10n.findingNearbyDrivers,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.appGreyColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : nearbyDrivers.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noDriversAvailable,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.appGreyColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: nearbyDrivers.length,
                        separatorBuilder: (context, index) => Divider(
                          color: AppColors.grayShade100,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final driver = nearbyDrivers[index];
                          return _buildDriverCard(driver, l10n);
                        },
                      ),
          ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDriverCard(NearbyDriver driver, AppLocalizations l10n) {
    // Calculate filled stars based on rating (0-5)
    final int filledStars = driver.rating.round().clamp(0, 5);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: Column(
        children: [
          Row(
            children: [
              // Profile image from driver data
              ClipOval(
                child: driver.profilePicture != null && driver.profilePicture!.isNotEmpty
                    ? Image.network(
                        // 'https://picsum.photos/250?image=9', // static placeholder
                        driver.profilePicture!,
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayShade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.appGreyColor,
                              size: 30.sp,
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayShade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.appGreyColor,
                          size: 30.sp,
                        ),
                      ),
              ),
              SizedBox(width: 12.sp),

              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4.sp),
                    // Rating stars based on driver's actual rating
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            color: index < filledStars ? Colors.yellow : Colors.grey,
                            size: 14.sp,
                          );
                        }),
                        SizedBox(width: 4.sp),
                        Text(
                          '(${driver.totalReviews})',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.appGreyColor,
                          ),
                        ),
                      ],
                    ),

                    if (driver.carInformation != null)
                      Text(
                        '${driver.carInformation!.brand} ${driver.carInformation!.model}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.appGreyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Distance and price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    // Display dynamic bid amount or default '--'
                    driverBids[driver.id] != null
                        ? formatPrice(driverBids[driver.id])
                        : driver.bidAmount != null
                            ? formatPrice(driver.bidAmount)
                            : '--',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: driverBids[driver.id] != null || driver.bidAmount != null
                          ? AppColors.primaryColor
                          : AppColors.darkColor,
                    ),
                  ),
                  Text(
                    '${(driver.distance / 1000).toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.appGreyColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.sp),

          // Accept button — only visible after new-offer is received for this driver
          if (driverRideIds.containsKey(driver.id)) Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 100.h,
              height: 40.h,
              child: CustomButton(
              height: 40,
              radius: 5,
              onPressed: (isAccepting && acceptingDriverId == driver.id)
                  ? null
                  : () async {
                      // Check if this driver has submitted an offer
                      final rideId = driverRideIds[driver.id];
                      if (rideId != null && rideId.isNotEmpty) {
                        _logger.i('Accepting offer - rideId: $rideId, driverId: ${driver.id}');

                        // Set loading state and store accepted driver data
                        setState(() {
                          isAccepting = true;
                          acceptingDriverId = driver.id;
                          acceptedDriver = driver;
                          acceptedBidAmount = driverBids[driver.id] ?? driver.bidAmount;
                        });

                        // Remove nearest-driver markers — single driver tracking takes over
                        Get.find<HomePageController>().clearNearestDriverMarkers();

                        // Emit accept-ride socket event
                        final accepted = await SocketIoService.to.emitAcceptRide(
                          rideId: rideId,
                          driverId: driver.id,
                        );
						if (!accepted && mounted) {
						  setState(() { isAccepting = false; acceptingDriverId = null; });
						  AppSnackbar.snackbar(AppLocalization.tr.errorTitle, AppLocalization.tr.rideNoLongerAvailableMessage);
						  return;
						}

                        _logger.i('Accept-ride emitted successfully, waiting for socket response...');
                        // Navigation will happen when ride-accepted event is received from socket
                      } else {
                        _logger.w('No offer found for driver ${driver.id}, cannot accept');
                      }
                    },
              title: (isAccepting && acceptingDriverId == driver.id)
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                    l10n.acceptButton,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14.sp,
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
