import 'package:flutter/material.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/ongoing_trip_details.dart';

/// A current trip, seen by its driver: the shared trip screen, showing the
/// rider instead of the driver.
class DriverOngoingTripDetails extends StatelessWidget {
  final String rideId;

  const DriverOngoingTripDetails({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) => OngoingTripDetails(rideId: rideId, asDriver: true);
}
