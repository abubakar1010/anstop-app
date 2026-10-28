import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/feature/driver/my_trip/controller/my_trip_controller.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/view/driver_completed_trip_details.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/view/driver_ongoing_trip_details.dart';
import 'package:ride_sharing/utils/driver/driver_custom_drawer.dart';
import 'package:ride_sharing/widgets/custom_app_bar_title.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

import '../../../../widgets/custom_horizontal_line.dart';
import '../../../../widgets/custom_toggle_button.dart';
import '../utils/trip_card.dart';

class MyTripPage extends StatefulWidget {
  MyTripPage({Key? key}) : super(key: key);

  @override
  State<MyTripPage> createState() => _MyTripPageState();
}

class _MyTripPageState extends State<MyTripPage> {
  // Instance fields, not file-level globals — see the note in my_ride.dart.
  final MyTripController controller = Get.put(MyTripController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBarTitle(scaffoldKey: _scaffoldKey),
      drawer: DriverCustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => ToggleButtonsWidget(
              isOngoing: controller.isOngoing.value,
              onToggleChanged: controller.onToggleChanged,
            )),

            CustomHorizontalLine(
              color: AppColors.togglebuttonColor,
              thickness: 1,
            ),
            SizedBox(height: 10.h),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (controller.trips.isEmpty) {
                  return Center(child: Text(AppLocalization.tr.noRidesFoundMessage));
                }

                return RefreshIndicator(
                  onRefresh: controller.loadTrips,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.trips.length,
                    itemBuilder: (_, index) {
                      final trip = controller.trips[index];
                      return MyTripCardWidget(
                        date: DateFormat.yMMMd().format(trip.createdAt),
                        time: DateFormat.jm().format(trip.createdAt),
                        pickup: trip.pickup?.name ?? '',
                        dropoff: trip.destination?.name ?? '',
                        onViewDetails: () {
                          if (controller.isOngoing.value) {
                            Get.to(() => DriverOngoingTripDetails(rideId: trip.id));
                          } else {
                            Get.to(() => DriverCompletedTripDetails(rideId: trip.id));
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
