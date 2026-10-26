import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/app/helpers/image_picker_helper.dart';
import 'package:ride_sharing/feature/auth/controller/car_information_controller.dart';
import 'package:ride_sharing/feature/auth/passenger/terms_of_services.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CarInformationScreen extends GetView<CarInformationController> {
  const CarInformationScreen({super.key});

  /// Pops with `Navigator` rather than `Get.back()`: GetX swallows the pop (and
  /// throws on its own dead snackbar controller) whenever a snackbar is still
  /// registered, which is exactly the state a failed validation leaves behind.
  Future<void> _onSubmit(BuildContext context) async {
    // Paint the inline errors first so the user sees *which* fields are wrong,
    // then let saveSection report the first problem and record the status.
    controller.validateCarDetails();
    if (!controller.saveSection()) return;
    await AppSnackbar.dismiss();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving without pressing Submit must still leave the documents list
      // showing the truth. Covers every exit: the back arrow below, the iOS
      // swipe-back gesture and the Android system back button.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) controller.refreshSectionStatus();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
          child: Obx(() {
            final isUploading =
                controller.isLicensePlateImageUploading.value ||
                controller.isRegCertFrontImageUploading.value ||
                controller.isRegCertBackImageUploading.value;
            return CustomButton(
              onPressed: isUploading ? () {} : () => _onSubmit(context),
              label: isUploading ? AppLocalization.tr.uploadingButton : AppLocalization.tr.submitButton,
            );
          }),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.sp),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalization.tr.carInformationTitle,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 29.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.carNameLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    controller: controller.carBrandTEController,
                    validator: controller.validateCarName,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 5.sp),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.carModelLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    controller: controller.carModelTEController,
                    validator: controller.validateCarModel,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 5.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.yearOfManufactureLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    controller: controller.carYearTEController,
                    validator: controller.validateCarYear,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.numberPlateLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    controller: controller.licensePlateNumberTEController,
                    validator: controller.validateLicensePlate,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.uploadLicensePlateLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => GestureDetector(
                      onTap: () async {
                        final image =
                            await ImagePickerHelper.pickImageWithOptions(
                              context,
                            );
                        if (image != null) {
                          await controller.uploadAndSelectLicensePlateImage(
                            image,
                          );
                        }
                      },
                      child: CustomUploadItems(
                        borderWidth: 1.0,
                        borderColor: Colors.black,
                        uploadedImage: controller.licensePlateImage.value,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.registrationCertNumberLabel,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    controller: controller.registrationCertNumberTEController,
                    validator: controller.validateRegistrationCertNumber,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.uploadCarPictureFront,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => GestureDetector(
                      onTap: () async {
                        final image =
                            await ImagePickerHelper.pickImageWithOptions(
                              context,
                            );
                        if (image != null) {
                          await controller.uploadAndSelectRegCertFrontImage(
                            image,
                          );
                        }
                      },
                      child: CustomUploadItems(
                        borderWidth: 1.0,
                        borderColor: Colors.black,
                        uploadedImage: controller.regCertFrontImage.value,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4.sp),
                      child: Text(
                        AppLocalization.tr.uploadCarPictureBack,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => GestureDetector(
                      onTap: () async {
                        final image =
                            await ImagePickerHelper.pickImageWithOptions(
                              context,
                            );
                        if (image != null) {
                          await controller.uploadAndSelectRegCertBackImage(
                            image,
                          );
                        }
                      },
                      child: CustomUploadItems(
                        borderWidth: 1.0,
                        borderColor: Colors.black,
                        uploadedImage: controller.regCertBackImage.value,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
