import 'package:ride_sharing/custom_assets/app_string.dart';
import 'package:ride_sharing/feature/auth/controller/car_information_controller.dart';
import 'package:ride_sharing/feature/auth/controller/driving_license_controller.dart';
import 'package:ride_sharing/feature/auth/controller/national_id_controller.dart';
import 'package:ride_sharing/feature/auth/controller/upload_documents_controller.dart';
import 'package:ride_sharing/feature/auth/controller/upload_profile_picture_controller.dart';
import 'package:ride_sharing/feature/auth/driver/car_information_screen.dart';
import 'package:ride_sharing/feature/auth/driver/driving_license_screen.dart';
import 'package:ride_sharing/feature/auth/driver/national_id_screen.dart';
import 'package:ride_sharing/feature/auth/driver/upload_profile_picture.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

class UploadYourDocuments extends GetView<UploadDocumentsController> {
  UploadYourDocuments({super.key});
  NationalIdController nationalIdController = Get.put(NationalIdController());
  DrivingLicenseController drivingLicenseController = Get.put(
    DrivingLicenseController(),
  );
  CarInformationController carInformationController = Get.put(
    CarInformationController(),
  );
  UploadProfilePictureController uploadProfilePictureController = Get.put(
    UploadProfilePictureController(),
  );
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
        child: Obx(
          () => CustomButton(
            onPressed: controller.isLoading.value
                ? () {}
                : () => controller.submitDriverOnboard(),
            label: controller.isLoading.value
                ? "Submitting..."
                : AppString.submitButton,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15.h),
              Text(
                AppString.uploadDocumentsTitle,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppString.uploadDocumentsMessage1,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 4.h),
                    Center(
                      child: Text(
                        AppString.uploadDocumentsMessage2,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 29.h),
              CustomBoxItems(
                documentTitle: AppString.nationalIdLabel,
                isUploaded: false,
                onTap: () {
                  Get.to(() => NationalIdScreen());
                },
              ),
              CustomBoxItems(
                documentTitle: AppString.drivingLicenceLabel,
                isUploaded: false,
                onTap: () {
                  Get.to(() => DrivingLicenseScreen());
                },
              ),
              CustomBoxItems(
                documentTitle: AppString.carInformationLabel,
                isUploaded: false,
                onTap: () {
                  Get.to(() => CarInformationScreen());
                },
              ),
              CustomBoxItems(
                documentTitle: AppString.yourPictureLabel,
                isUploaded: false,
                onTap: () {
                  Get.to(() => UploadProfilePictureScreen());
                },
              ),
              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
