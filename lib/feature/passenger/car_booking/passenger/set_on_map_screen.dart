import 'package:flutter/cupertino.dart';
import 'package:ride_sharing/custom_assets/app_image.dart';
import 'package:ride_sharing/feature/passenger/car_booking/passenger/controller/pick_up_location_controller.dart';
import 'package:ride_sharing/feature/auth/view/email_validation_screen.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/widgets/custom_location_button.dart';

import '../../../../routes/app_routes.dart';
import '../../set_location/view/set_location_option_page.dart';
class SetOnMapScreen extends StatelessWidget {
  SetOnMapScreen({super.key});
  final TextEditingController locationTEController = TextEditingController();
  PickUpLocationController _pickUpLocationController = Get.put(PickUpLocationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,  // Aligning the image at the center
              children: [
                SizedBox(height: 66.h),
                CustomTextField(
                  onTap: (){
                    Get.toNamed(AppRoutes.pickUpLocationScreen);
                  },
                  controller: locationTEController,
                  prefixIcon: Icon(Icons.location_on, color: AppColors.primaryColor),
                  suffixIcon: Icon(CupertinoIcons.search_circle),
                  hintText: AppLocalization.tr.whereAreYouHeadedHint,
                  borderColor: AppColors.primaryColor,
                  borderRadio: 20,
                ),
                SizedBox(height: 8),// Optional, adjust if needed
                SetLocationOptionCard(
                  icon: Icons.pin_drop_rounded,
                  title: AppLocalization.tr.setOnMapOption,
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.setLocationScreen,
                      arguments: {'addressType': 'SET_ON_MAP'},
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Container(
                    height: 70.h,
                    width: 345.w,
                    decoration: BoxDecoration(
                      color: AppColors.greenShade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomLocationButton(
                            imageUrl: AppImage.home,
                            mainText: AppLocalization.tr.homeOption,
                            subText: AppLocalization.tr.setAddressSubtitle,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.setLocationScreen,
                                arguments: {'addressType': 'HOME'},
                              );
                            },
                          ),
                          VerticalDivider(color: AppColors.white, width: 2),
                          CustomLocationButton(
                            imageUrl: AppImage.briefcase,
                            mainText: AppLocalization.tr.workOption,
                            subText: AppLocalization.tr.setAddressSubtitle,
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.setLocationScreen,
                                arguments: {'addressType': 'WORK'},
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // Recent places will be listed here once they are stored; the
                // previous entries were hard-coded samples.
                ///If no location is found
                // Center(
                //   child: Image.asset(
                //     'assets/images/no_data.png',
                //     width: 250.w,
                //     height: 250.h,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                // SizedBox(height: 5.h),
                // Center(child: Text('Not Found',style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold),)),
                //
                // SizedBox(height: 5.h),
                // Text('Sorry the keyword you entered cannot be found, please ',style: TextStyle(color: AppColors.appGreyColor),),
                // Center(child: Text('check again or search with another keyword',style: TextStyle(color: AppColors.appGreyColor),)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

