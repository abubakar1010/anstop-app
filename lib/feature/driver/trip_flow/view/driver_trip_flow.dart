import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/driver/homepage/controller/driver_home_controller.dart';
import 'package:ride_sharing/feature/driver/trip_flow/model/ride_request_model.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/services/ride_session_controller.dart';
import 'package:ride_sharing/feature/driver/trip_flow/view/trip_completion_payment_dialogs.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_horizontal_line.dart';
import 'package:ride_sharing/widgets/custom_vertical_line.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';

// import your app colors here
// import '../../../../app/message_utils/app_colors.dart';

// Mock colors - replace with your actual AppColors


// Trip model
part 'driver_trip_flow_state.part.dart';
part 'driver_trip_request_sheets.part.dart';
part 'driver_trip_active_sheets.part.dart';

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
