import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:ride_sharing/feature/passenger/set_location/controller/set_location_controller.dart';
import 'package:ride_sharing/widgets/app_google_map.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/home_links/home_links.dart';
import 'package:ride_sharing/app/utils/app_colors.dart';
import 'package:ride_sharing/services/app_config.dart';

class SetLocationScreen extends StatelessWidget {
  const SetLocationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SetLocationController>(
        builder: (controller) {
          return Stack(
            children: [
              AppGoogleMap(
                camera: controller,
                markers: controller.markers,
              ),
              if (controller.isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),

              // Set Location Card (shown when showConfirmCard is false)
              if (controller.currentPosition != null &&
                  !controller.isLoading &&
                  !controller.showConfirmCard)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSetLocationCard(context, controller),
                ),

              // Confirm Address Card (shown when showConfirmCard is true)
              if (controller.currentPosition != null &&
                  !controller.isLoading &&
                  controller.showConfirmCard)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildConfirmAddressCard(context, controller),
                ),

              // Back button
              Positioned(
                top: 40,
                left: 16,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 25,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Loading overlay for submission
              if (controller.isSubmitting)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Build the Set Location card (first step for SET_ON_MAP flow)
  Widget _buildSetLocationCard(
      BuildContext context, SetLocationController controller) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Card(
        color: AppColors.white,
        margin: EdgeInsets.zero,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google Place Autocomplete TextField
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: controller.addressController,
                        googleAPIKey: AppConfig.googleMapsApiKey,
                        inputDecoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalization.tr.whereAreYouHeadedHint,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.appGreyColor,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.darkColor,
                        ),
                        debounceTime: 200,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          if (prediction.lat != null &&
                              prediction.lng != null) {
                            controller.latitudeController.text =
                                prediction.lat.toString();
                            controller.longitudeController.text =
                                prediction.lng.toString();
                            controller.updateMarkerFromAddress();
                          }
                        },
                        itemClick: (Prediction prediction) {
                          controller.addressController.text =
                              prediction.description ?? "";
                          FocusScope.of(context).unfocus();
                        },
                        containerHorizontalPadding: 0,
                        itemBuilder:
                            (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prediction.description ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColors.darkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        isCrossBtnShown: false,
                      ),
                    ),
                  ],
                ),
              ),

              // Saved Bookmarks List
              if (controller.shouldShowBookmarksList) ...[
                SizedBox(height: 16),
                Text(
                  AppLocalization.tr.savedAddressLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.darkColor,
                  ),
                ),
                SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.savedBookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = controller.savedBookmarks[index];
                      final name = bookmark['name'] as String;
                      return InkWell(
                        onTap: () {
                          controller.selectBookmark(index);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.grayShade100.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bookmark,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColors.darkColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.appGreyColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 300.w,
                    child: CustomButton(
                      onPressed: () {
                        controller.onSetLocationTapped();
                      },
                      title: Text(
                        AppLocalization.tr.setLocationButton,
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.bookmark_fill,
                    color: AppColors.primaryColor,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Build the Confirm Address card (second step / direct for HOME/WORK)
  Widget _buildConfirmAddressCard(
      BuildContext context, SetLocationController controller) {
    return Container(
      width: double.infinity,
      child: Card(
        color: AppColors.white,
        margin: EdgeInsets.zero,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Google Place Autocomplete TextField
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: controller.addressController,
                        googleAPIKey: AppConfig.googleMapsApiKey,
                        inputDecoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppLocalization.tr.whereAreYouHeadedHint,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColors.appGreyColor,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.darkColor,
                        ),
                        debounceTime: 200,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          if (prediction.lat != null &&
                              prediction.lng != null) {
                            controller.latitudeController.text =
                                prediction.lat.toString();
                            controller.longitudeController.text =
                                prediction.lng.toString();
                            controller.updateMarkerFromAddress();
                          }
                        },
                        itemClick: (Prediction prediction) {
                          controller.addressController.text =
                              prediction.description ?? "";
                          FocusScope.of(context).unfocus();
                        },
                        containerHorizontalPadding: 0,
                        itemBuilder:
                            (context, index, Prediction prediction) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    prediction.description ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColors.darkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        isCrossBtnShown: false,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Confirm button with dynamic text
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: controller.isSubmitting
                      ? null
                      : () {
                          controller.onConfirmAddressTapped();
                        },
                  title: controller.isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          controller.getConfirmButtonText(),
                          style: TextStyle(color: AppColors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
