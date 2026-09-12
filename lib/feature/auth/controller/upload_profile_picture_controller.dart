import 'dart:io';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

class UploadProfilePictureController extends GetxController {
  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isImageUploading = false.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxBool isUploaded = false.obs;
  final RxString errorMessage = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
  }

  // ==================== Business Logic ====================
  Future<void> uploadAndSelectImage(File image) async {
    try {
      isImageUploading.value = true;
      profileImage.value = image;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        AppSnackbar.error(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.sessionExpiredMessage,
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
          profileImageUrl.value = data[0];
        } else {
          errorMessage.value = 'Failed to get image URL from response';
          AppSnackbar.error(
            AppLocalization.tr.uploadFailedTitle,
            AppLocalization.tr.imageUrlMissingMessage,
          );
        }
      } else {
        debugPrint('upload_profile_picture_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.uploadFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('upload_profile_picture_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isImageUploading.value = false;
    }
  }

  void removeImage() {
    profileImage.value = null;
    profileImageUrl.value = '';
  }

  // ==================== Validation ====================
  /// Returns `null` when this section is complete, otherwise the reason why not.
  String? validateSection() {
    if (isImageUploading.value) {
      return AppLocalization.tr.profilePictureUploadingMessage;
    }
    if (profileImageUrl.value.isEmpty) {
      return AppLocalization.tr.uploadProfilePictureRequiredMessage;
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
}
