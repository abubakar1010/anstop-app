import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/feature/passenger/car_booking/utils/driver_status_widget.dart';
import 'package:ride_sharing/utils/user_info_section.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import '../../../../app/utils/app_colors.dart';
import '../../../../widgets/custom_horizontal_line.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';


class RideBegunBottomSheet extends StatefulWidget {
  final String driverName;
  final String? driverProfilePicture;
  final double driverRating;
  final int driverTotalReviews;
  final String bidAmount;
  final String tripDistance;
  final String destinationAddress;

  const RideBegunBottomSheet({
    Key? key,
    this.driverName = '',
    this.driverProfilePicture,
    this.driverRating = 0.0,
    this.driverTotalReviews = 0,
    this.bidAmount = '',
    this.tripDistance = '',
    this.destinationAddress = '',
  }) : super(key: key);

  @override
  _RideBegunBottomSheetState createState() => _RideBegunBottomSheetState();
}

class _RideBegunBottomSheetState extends State<RideBegunBottomSheet> {
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Use dynamic data or fallback to static
    final displayName = widget.driverName.isNotEmpty ? widget.driverName : 'John Doe';
    final displayImageUrl = widget.driverProfilePicture ?? 'https://picsum.photos/250?image=9';
    final displayRating = widget.driverRating > 0 ? widget.driverRating : 3.54;
    final displayTrips = widget.driverTotalReviews > 0 ? widget.driverTotalReviews : 3;
    final displayPrice = widget.bidAmount.isNotEmpty ? formatPrice(widget.bidAmount) : '€24';
    final displayDistance = widget.tripDistance.isNotEmpty ? '${widget.tripDistance} km' : '28 km';
    final displayDestination = widget.destinationAddress.isNotEmpty
        ? widget.destinationAddress
        : 'Green Road Dhaka';

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.only(top: 20.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          DriverStatusWidget(
            statusText: l10n.yourRideHasBegun,
            circleColor: Colors.green,
          ),
          CustomHorizontalLine(thickness: 5.sp,),

        //  SizedBox(height: 16.sp),
          /// User Info Section with Avatar and Rating
          UserInfoSection(
            imageUrl: displayImageUrl,
            name: displayName,
            rating: displayRating,
            trips: displayTrips,
            profession: AppLocalization.tr.professionalLabel,
            price: displayPrice,
            distance: displayDistance,
          ),
        //  SizedBox(height: 16.sp),
          CustomHorizontalLine(thickness: 5.sp,),
           Padding(
            padding:  EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.yourTrip,style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold),),
                      SizedBox(height: 2.sp,),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,color: AppColors.greenShade50,),
                          Expanded(
                            child: Text(
                              displayDestination,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
               Text(displayDistance),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
