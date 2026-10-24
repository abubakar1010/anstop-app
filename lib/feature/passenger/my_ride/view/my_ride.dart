import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/feature/passenger/my_ride/controller/my_ride_controller.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/complete_trip_details.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/ongoing_trip_details.dart';
import 'package:ride_sharing/widgets/custom_app_bar_title.dart';
import 'package:ride_sharing/utils/passenger/passenger_custom_drawer.dart';
import 'package:intl/intl.dart';
import '../../../../custom_assets/app_image.dart';
import '../../../../widgets/custom_horizontal_line.dart';
import '../../../../widgets/custom_toggle_button.dart';
import '../utils/ride_card.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class MyRidePage extends StatefulWidget {
  MyRidePage({Key? key}) : super(key: key);

  @override
  State<MyRidePage> createState() => _MyRidePageState();
}
class _MyRidePageState extends State<MyRidePage> {
  // Instance fields, not file-level globals: a single shared GlobalKey is
  // claimed by whichever Scaffold mounted last, so during a push/pop
  // transition (two instances alive at once) the key detaches from this page
  // and the drawer button stops responding.
  final MyRideController controller = Get.put(MyRideController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBarTitle(scaffoldKey: _scaffoldKey),
      drawer: PassengerCustomDrawer(),
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

                if (controller.rides.isEmpty) {
                  return Center(child: Text(AppLocalization.tr.noRidesFoundMessage));
                }

                return ListView.builder(
                  itemCount: controller.rides.length,
                  itemBuilder: (_, index) {
                    final ride = controller.rides[index];
                    final formattedDate = DateFormat.yMMMd().format(ride.createdAt);
                    final formattedTime = DateFormat.jm().format(ride.createdAt);
                    return MyRideCardWidget(
                      date: formattedDate,
                      time: formattedTime,
                      pickup: ride.pickup?.name ?? '',
                      dropoff: ride.destination?.name ?? '',
                      imageUrl: ride.driver.profilePicture ?? '',
                      onViewDetails: () {
                        if (controller.isOngoing.value) {
                          Get.to(() => OngoingTripDetails(rideId: ride.id));
                        } else {
                          Get.to(() => CompletedTripDetails(rideId: ride.id));
                        }
                      },
                    );
                  },
                );
              }),
            ),

          ],
        ),
      ),
    );
  }
}
