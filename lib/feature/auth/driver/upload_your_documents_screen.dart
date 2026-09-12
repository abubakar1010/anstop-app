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
  const UploadYourDocuments({super.key});

  @override
  Widget build(BuildContext context) {
    // Registered by UploadDocumentsBinding, so the entered data outlives a
    // trip into one of the document screens.
    final nationalIdController = Get.find<NationalIdController>();
    final drivingLicenseController = Get.find<DrivingLicenseController>();
    final carInformationController = Get.find<CarInformationController>();
    final profilePictureController = Get.find<UploadProfilePictureController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Navigator, not Get.back(): see AppSnackbar.dismiss().
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
          child: Obx(
            () => CustomButton(
              onPressed: controller.isLoading.value
                  ? () {}
                  : () => controller.submitDriverOnboard(),
              label: controller.isLoading.value
                  ? 'Submitting...'
                  : AppLocalization.tr.submitButton,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15.h),
              Text(
                AppLocalization.tr.uploadDocumentsTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              Text(
                '${AppLocalization.tr.uploadDocumentsMessage1} '
                '${AppLocalization.tr.uploadDocumentsMessage2}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.appGreyColor,
                ),
              ),
              SizedBox(height: 29.h),
              Obx(
                () => CustomBoxItems(
                  documentTitle: AppLocalization.tr.nationalIdLabel,
                  icon: Icons.badge_outlined,
                  isUploaded: nationalIdController.isUploaded.value,
                  onTap: () => Get.to(() => const NationalIdScreen()),
                ),
              ),
              Obx(
                () => CustomBoxItems(
                  documentTitle: AppLocalization.tr.drivingLicenceLabel,
                  icon: Icons.credit_card_outlined,
                  isUploaded: drivingLicenseController.isUploaded.value,
                  onTap: () => Get.to(() => const DrivingLicenseScreen()),
                ),
              ),
              Obx(
                () => CustomBoxItems(
                  documentTitle: AppLocalization.tr.carInformationLabel,
                  icon: Icons.directions_car_outlined,
                  isUploaded: carInformationController.isUploaded.value,
                  onTap: () => Get.to(() => const CarInformationScreen()),
                ),
              ),
              Obx(
                () => CustomBoxItems(
                  documentTitle: AppLocalization.tr.yourPictureLabel,
                  icon: Icons.person_outline,
                  isUploaded: profilePictureController.isUploaded.value,
                  onTap: () => Get.to(() => const UploadProfilePictureScreen()),
                ),
              ),
              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
