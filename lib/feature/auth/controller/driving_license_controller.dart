import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrivingLicenseController extends GetxController {
  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== Text Controllers ====================
  final TextEditingController licenseNumberTEController =
      TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isFrontImageUploading = false.obs;
  final RxBool isBackImageUploading = false.obs;
  final Rx<File?> frontImage = Rx<File?>(null);
  final Rx<File?> backImage = Rx<File?>(null);
  final RxString frontImageUrl = ''.obs;
  final RxString backImageUrl = ''.obs;
  final RxBool isUploaded = false.obs;
  final RxString errorMessage = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    licenseNumberTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  Future<void> uploadAndSelectFrontImage(File image) async {
    try {
      isFrontImageUploading.value = true;
      frontImage.value = image;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        AppSnackbar.error(
          'Error',
          'Access token not found. Please login again.',
        );
        return;
      }

      final response = await _authService.uploadFiles(
        accessToken: accessToken,
        files: [image],
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        if (data != null && data is List && data.isNotEmpty) {
          frontImageUrl.value = data[0];
        } else {
          errorMessage.value = 'Failed to get image URL from response';
          AppSnackbar.error(
            'Upload Failed',
            'Failed to get image URL from response',
          );
        }
      } else {
        errorMessage.value = response.errorMessage;
        AppSnackbar.error(
          'Upload Failed',
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to upload image. Please try again.',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      AppSnackbar.error('Error', e.toString());
    } finally {
      isFrontImageUploading.value = false;
    }
  }

  Future<void> uploadAndSelectBackImage(File image) async {
    try {
      isBackImageUploading.value = true;
      backImage.value = image;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        AppSnackbar.error(
          'Error',
          'Access token not found. Please login again.',
        );
        return;
      }

      final response = await _authService.uploadFiles(
        accessToken: accessToken,
        files: [image],
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        if (data != null && data is List && data.isNotEmpty) {
          backImageUrl.value = data[0];
        } else {
          errorMessage.value = 'Failed to get image URL from response';
          AppSnackbar.error(
            'Upload Failed',
            'Failed to get image URL from response',
          );
        }
      } else {
        errorMessage.value = response.errorMessage;
        AppSnackbar.error(
          'Upload Failed',
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to upload image. Please try again.',
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      AppSnackbar.error('Error', e.toString());
    } finally {
      isBackImageUploading.value = false;
    }
  }

  void removeFrontImage() {
    frontImage.value = null;
    frontImageUrl.value = '';
  }

  void removeBackImage() {
    backImage.value = null;
    backImageUrl.value = '';
  }

  // ==================== Validation ====================
  bool validateImages() {
    return frontImage.value != null && backImage.value != null;
  }

  /// Returns `null` when this section is complete, otherwise the reason why not.
  String? validateSection() {
    if (licenseNumberTEController.text.trim().isEmpty) {
      return 'Driving license number is required';
    }
    if (isFrontImageUploading.value || isBackImageUploading.value) {
      return 'Please wait until the Driving License images finish uploading';
    }
    if (frontImageUrl.value.isEmpty || backImageUrl.value.isEmpty) {
      return 'Please upload both front and back of Driving License';
    }
    return null;
  }

  /// Validates the section, records the result for the documents list and
  /// reports the first problem to the user. Returns true when complete.
  bool saveSection() {
    final error = validateSection();
    isUploaded.value = error == null;
    if (error != null) {
      AppSnackbar.error('Validation Error', error);
      return false;
    }
    return true;
  }

  // ==================== Navigation ====================
  void goBack() {
    // Get.back();
  }

  void skipUpload() {
    // Get.back(result: false);
  }
}
