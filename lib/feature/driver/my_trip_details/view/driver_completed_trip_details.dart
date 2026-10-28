import 'package:flutter/material.dart';
import 'package:ride_sharing/feature/passenger/trip_details/view/complete_trip_details.dart';

/// A finished trip, seen by its driver: the shared trip screen, showing the
/// rider instead of the driver.
class DriverCompletedTripDetails extends StatelessWidget {
  final String rideId;

  const DriverCompletedTripDetails({super.key, required this.rideId});

  @override
  Widget build(BuildContext context) => CompletedTripDetails(rideId: rideId, asDriver: true);
}
