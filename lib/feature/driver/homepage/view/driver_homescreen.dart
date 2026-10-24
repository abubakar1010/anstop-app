import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/feature/driver/homepage/controller/driver_home_controller.dart';
import 'package:ride_sharing/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:ride_sharing/feature/driver/trip_flow/view/driver_trip_flow.dart';
import 'package:ride_sharing/utils/driver/driver_custom_drawer.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import '../../../../app/utils/app_colors.dart';
import '../utils/driver_google_map_widget.dart';
import 'package:ride_sharing/utils/passenger/passenger_custom_drawer.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isOnline = false;
  bool _showPulseIndicator = false;
  Timer? _pulseTimer;
  late AnimationController _animationController;
  late Animation<double> _rippleAnimation;
  late DriverHomeScreenController _homeController;

  // Bottom sheet visibility states
  final RxBool _showTripFlow = false.obs;
  final Rx<TripState?> _tripFlowInitialState = Rx<TripState?>(null);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleAnimation = Tween<double>(begin: 80, end: 120).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Ensure profile controller is available before body builds
    Get.put(DriverProfileController());

    // Initialize controller and set up ride request listener
    _homeController = Get.find<DriverHomeScreenController>();
    _setupRideRequestObserver();
  }

  void _setupRideRequestObserver() {
    // Listen for new ride requests
    ever(_homeController.hasNewRideRequest, (bool hasRequest) {
      if (hasRequest && mounted && !_showTripFlow.value) {
        setState(() {
          _isOnline = false;
        });
        _animationController.forward();
        _showDriverTripFlow();
      }
    });

    // Listen for ride accepted (after driver submits bid and passenger accepts)
    ever(_homeController.isRideAccepted, (bool isAccepted) {
      if (isAccepted && mounted && !_showTripFlow.value) {
        _showDriverTripFlowWithAcceptedState();
      }
    });
  }

  void _showDriverTripFlowWithAcceptedState() {
    if (_showTripFlow.value) return;

    _tripFlowInitialState.value = TripState.tripTaken;
    _showTripFlow.value = true;
  }

  void _showDriverTripFlow() {
    // Only show if there's a valid ride request and bottom sheet is not already open
    if (_showTripFlow.value) return;
    if (_homeController.currentRideRequest.value == null) return;

    _tripFlowInitialState.value = null;
    _showTripFlow.value = true;
  }

  void _hideTripFlow() {
    _showTripFlow.value = false;
    _tripFlowInitialState.value = null;
    _homeController.clearRideRequest();
    _homeController.clearRideAccepted();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: CustomToggleSwitch(
          isOnline: _isOnline,
          onChanged: (value) {
            setState(() {
              _isOnline = value;
              if (_isOnline) {
                // Show pulse indicator for 2 seconds
                _showPulseIndicator = true;

                // Cancel any existing timer
                _pulseTimer?.cancel();

                // Hide after 2 seconds
                _pulseTimer = Timer(const Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _showPulseIndicator = false;
                    });
                  }
                });

                _animationController.forward();
                _homeController.startLocationUpdates();
              } else {
                _animationController.stop();
                // Immediately hide pulse when going offline
                _showPulseIndicator = false;
                _pulseTimer?.cancel();
                _homeController.stopLocationUpdates();
              }
            });
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconWidget(
              width: 40.0,
              height: 40.0,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
      drawer:  DriverCustomDrawer(),
      body: GetBuilder<DriverHomeScreenController>(
        init: DriverHomeScreenController(),
        builder: (controller) {
          return Stack(
            children: [
              // 🗺️ Map
              const DriverGoogleMapWidget(),

              // 🌀 Loading state
              if (controller.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),

              // 🚗 Simulation toggle button (only show when route exists)
              if (controller.polylines.value.isNotEmpty)
                Positioned(
                  top: 70.h,
                  right: 16.w,
                  child: Obx(() => FloatingActionButton.small(
                    onPressed: () => controller.toggleSimulation(),
                    backgroundColor: controller.isSimulationMode.value
                        ? Colors.red
                        : AppColors.primaryColor,
                    child: Icon(
                      controller.isSimulationMode.value
                          ? Icons.stop
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  )),
                ),

              if (controller.currentPosition != null &&
                  !controller.isLoading &&
                  _showPulseIndicator) // 👈 Now controlled by timer flag
                Positioned.fill(
                  child: Center(
                    child: PulsingLocationIndicator(
                      animation: _rippleAnimation,
                      centerIcon: Icons.location_on,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.7),
                        AppColors.primaryColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

              //  Glass dialog (only when offline)
              // Glass dialog (only when offline)
              if (!_isOnline)
                Positioned(
                  bottom: 50.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: GlassCard(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.driverYouAreOffline,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.tesxtColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      l10n.driverGoOnlineMessage,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.tesxtColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isOnline = true;
                                    _animationController.forward();
                                  });
                                  _homeController.startLocationUpdates();
                                },
                                child: Text(
                                  l10n.driverGoOnlineButton,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Account inactive overlay — non-modal, AppBar/drawer stay active
              Obx(() {
                final driverProfileController = Get.find<DriverProfileController>();
                if (!driverProfileController.isAccountInactive.value) return const SizedBox.shrink();
                final l10n = AppLocalizations.of(context)!;
                return Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 24.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_clock, size: 48.sp, color: AppColors.primaryColor),
                              SizedBox(height: 16.h),
                              Text(
                                l10n.accountInactiveTitle,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                l10n.accountInactiveMessage,
                                style: TextStyle(fontSize: 14.sp),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Trip Flow Bottom Sheet - positioned at bottom, allows map interaction
              Obx(() => _showTripFlow.value
                  ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DriverTripFlow(
                        initialState: _tripFlowInitialState.value,
                        onDismiss: _hideTripFlow,
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }
}

// =============== REUSABLE WIDGETS ===============

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      // No fixed height — let content determine height so French text never overflows
      constraints: BoxConstraints(minHeight: 90.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.w,
        ),
        color: Colors.white.withOpacity(0.3),
      ),
      padding: padding,
      child: child,
    );
  }
}

class PulsingLocationIndicator extends StatelessWidget {
  final Animation<double> animation;
  final IconData centerIcon;
  final List<Color> colors;

  const PulsingLocationIndicator({
    super.key,
    required this.animation,
    required this.centerIcon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: animation.value.w,
              height: animation.value.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[2],
              ),
            ),
            // Middle ring
            Container(
              width: (animation.value * 0.7).w,
              height: (animation.value * 0.7).w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[1],
              ),
            ),
            // Center pin
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[0],
              ),
              child: Icon(
                centerIcon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ],
        );
      },
    );
  }
}

class StatusAlertBanner extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const StatusAlertBanner({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isOnline
                  ? l10n.driverYouAreOnline
                  : l10n.driverYouAreOffline,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          ElevatedButton(
            onPressed: onToggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: isOnline
                  ? AppColors.violetShade
                  : AppColors.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              isOnline ? l10n.driverGoOfflineButton : l10n.driverGoOnline,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomToggleSwitch extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onChanged;

  const CustomToggleSwitch({
    super.key,
    required this.isOnline,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isOnline),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        width: 70.w,
        height: 36.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isOnline ? AppColors.primaryColor : Colors.grey[400],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isOnline ? 34.w : 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4.r,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isOnline ? Icons.location_on : Icons.location_on,
                  color: isOnline ? AppColors.primaryColor : AppColors.violetShade,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




