import 'package:ride_sharing/services/session_controller.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class NationalIdController extends GetxController {
  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== Text Controllers ====================
  final TextEditingController nidNumberTEController = TextEditingController();

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
    nidNumberTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  Future<void> uploadAndSelectFrontImage(File image) async {
    try {
      isFrontImageUploading.value = true;
      frontImage.value = image;
      errorMessage.value = '';

      // Get access token
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = AppLocalization.tr.sessionExpiredMessage;
        AppSnackbar.error(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.sessionExpiredMessage,
        );
        return;
      }

      // Upload file to get URL
      final response = await _authService.uploadFiles(
        accessToken: accessToken,
        files: [image],
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        if (data != null && data is List && data.isNotEmpty) {
          frontImageUrl.value = data[0];
        } else {
          errorMessage.value = AppLocalization.tr.imageUrlMissingMessage;
          AppSnackbar.error(
            AppLocalization.tr.uploadFailedTitle,
            AppLocalization.tr.imageUrlMissingMessage,
          );
        }
      } else {
        debugPrint('national_id_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.uploadFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('national_id_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isFrontImageUploading.value = false;
    }
  }

  Future<void> uploadAndSelectBackImage(File image) async {
    try {
      isBackImageUploading.value = true;
      backImage.value = image;
      errorMessage.value = '';

      // Get access token
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = AppLocalization.tr.sessionExpiredMessage;
        AppSnackbar.error(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.sessionExpiredMessage,
        );
        return;
      }

      // Upload file to get URL
      final response = await _authService.uploadFiles(
        accessToken: accessToken,
        files: [image],
      );

      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        if (data != null && data is List && data.isNotEmpty) {
          backImageUrl.value = data[0];
        } else {
          errorMessage.value = AppLocalization.tr.imageUrlMissingMessage;
          AppSnackbar.error(
            AppLocalization.tr.uploadFailedTitle,
            AppLocalization.tr.imageUrlMissingMessage,
          );
        }
      } else {
        debugPrint('national_id_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.uploadFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('national_id_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
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
    if (nidNumberTEController.text.trim().isEmpty) {
      return AppLocalization.tr.nationalIdNumberRequiredError;
    }
    if (isFrontImageUploading.value || isBackImageUploading.value) {
      return AppLocalization.tr.nationalIdImagesUploadingMessage;
    }
    if (frontImageUrl.value.isEmpty || backImageUrl.value.isEmpty) {
      return AppLocalization.tr.uploadNationalIdBothSidesMessage;
    }
    return null;
  }

  /// Validates the section, records the result for the documents list and
  /// reports the first problem to the user. Returns true when complete.
  bool saveSection() {
    final error = validateSection();
    isUploaded.value = error == null;
    if (error != null) {
      AppSnackbar.error(AppLocalization.tr.validationErrorTitle, error);
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
