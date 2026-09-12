import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/view/driver_completed_trip_details.dart';
import 'package:ride_sharing/feature/driver/my_trip_details/view/driver_ongoing_trip_details.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/complete_trip_details.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/ongoing_trip_details.dart';
import 'package:ride_sharing/utils/driver/driver_custom_drawer.dart';
import 'package:ride_sharing/widgets/custom_app_bar_title.dart';
import 'package:ride_sharing/utils/passenger/passenger_custom_drawer.dart';

import '../../../../widgets/custom_horizontal_line.dart';
import '../../../../widgets/custom_toggle_button.dart';
import '../utils/trip_card.dart';

class MyTripPage extends StatefulWidget {
  MyTripPage({Key? key}) : super(key: key);

  @override
  State<MyTripPage> createState() => _MyTripPageState();
}

class _MyTripPageState extends State<MyTripPage> {
  // Instance field, not a file-level global — see the note in my_ride.dart.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isOngoing = true;

  @override
  Widget build(BuildContext context) {

    final ongoingRides = [
      MyTripCardWidget(
        date: "22 Jan 2025",
        time: "10:45 AM",
        pickup: "Uttara Sector 10, Dhaka",
        dropoff: "Mirpur DOHS, Dhaka",
        onViewDetails: () => Get.to(DriverOngoingTripDetails()),
      ),
      MyTripCardWidget(
        date: "23 Jan 2025",
        time: "2:15 PM",
        pickup: "Banani, Dhaka",
        dropoff: "Dhanmondi 27, Dhaka",
        onViewDetails: () => Get.to(DriverOngoingTripDetails()),
      ),
    ];

    final completedRides = [
      MyTripCardWidget(
        date: "10 Jan 2025",
        time: "7:30 AM",
        pickup: "Mohakhali, Dhaka",
        dropoff: "Uttara 12, Dhaka",
        onViewDetails: () => Get.to(DriverCompletedTripDetails()),
      ),
      MyTripCardWidget(
        date: "05 Jan 2025",
        time: "6:10 PM",
        pickup: "Mirpur 1, Dhaka",
        dropoff: "Bashundhara R/A",
        onViewDetails: () => Get.to(DriverCompletedTripDetails()),
      ),
      MyTripCardWidget(
        date: "01 Jan 2025",
        time: "9:00 AM",
        pickup: "Farmgate",
        dropoff: "Gulshan 2",
        onViewDetails: () => Get.to(DriverCompletedTripDetails()),
      ),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBarTitle(scaffoldKey: _scaffoldKey),
      drawer: DriverCustomDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToggleButtonsWidget(
              isOngoing: isOngoing,
              onToggleChanged: (value) {
                setState(() => isOngoing = value);
              },
            ),

            CustomHorizontalLine(
              color: AppColors.togglebuttonColor,
              thickness: 1,
            ),
            SizedBox(height: 10.h),


            Expanded(
              child: ListView(
                children: isOngoing ? ongoingRides : completedRides,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
