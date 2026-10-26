import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/app/helpers/image_picker_helper.dart';
import 'package:ride_sharing/feature/auth/controller/upload_profile_picture_controller.dart';
import 'package:ride_sharing/feature/auth/passenger/terms_of_services.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';

class UploadProfilePictureScreen
    extends GetView<UploadProfilePictureController> {
  const UploadProfilePictureScreen({super.key});

  /// Pops with `Navigator` rather than `Get.back()`: GetX swallows the pop (and
  /// throws on its own dead snackbar controller) whenever a snackbar is still
  /// registered, which is exactly the state a failed validation leaves behind.
  Future<void> _onSubmit(BuildContext context) async {
    if (!controller.saveSection()) return;
    await AppSnackbar.dismiss();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
          child: Obx(
            () => CustomButton(
              onPressed: controller.isImageUploading.value
                  ? () {}
                  : () => _onSubmit(context),
              label: controller.isImageUploading.value
                  ? AppLocalization.tr.uploadingButton
                  : AppLocalization.tr.submitButton,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Text(
                  AppLocalization.tr.uploadPictureTitle,
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
                      AppLocalization.tr.uploadProfilePictureLabel,
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
                          await ImagePickerHelper.pickImageWithOptions(context);
                      if (image != null) {
                        await controller.uploadAndSelectImage(image);
                      }
                    },
                    child: CustomUploadItems(
                      borderWidth: 1.0,
                      borderColor: Colors.black,
                      uploadedImage: controller.profileImage.value,
                      child: Container(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 55.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
