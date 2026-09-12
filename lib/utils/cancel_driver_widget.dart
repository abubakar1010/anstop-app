import 'package:flutter/material.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import '../feature/passenger/car_booking/utils/driver_arrived_bottom_sheet.dart';

class CancelDriverWidget extends StatelessWidget {
  final Function onCancelPressed;

  // Constructor to receive a callback function for when the cancel button is pressed
  const CancelDriverWidget({Key? key, required this.onCancelPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppLocalization.tr.cancelRideQuestion),
          ElevatedButton(
            onPressed: () {
              // Handle button press
              onCancelPressed(); // Execute the passed callback

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed, // Background color of the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // Border radius
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Make the row size fit the content
              children: [
                // Space between the icon and the text
                Text(
                  AppLocalization.tr.cancelNowButton,
                  style: TextStyle(
                    color: Colors.white, // Text color
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.close,
                  color: Colors.white, // Icon color
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
