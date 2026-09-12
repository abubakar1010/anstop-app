import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class CarInformationController extends GetxController {
  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== Text Controllers ====================
  final TextEditingController carBrandTEController = TextEditingController();
  final TextEditingController carModelTEController = TextEditingController();
  final TextEditingController carYearTEController = TextEditingController();
  final TextEditingController licensePlateNumberTEController =
      TextEditingController();
  final TextEditingController registrationCertNumberTEController =
      TextEditingController();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isLicensePlateImageUploading = false.obs;
  final RxBool isRegCertFrontImageUploading = false.obs;
  final RxBool isRegCertBackImageUploading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUploaded = false.obs;
  final formKey = GlobalKey<FormState>();

  // Images
  final Rx<File?> licensePlateImage = Rx<File?>(null);
  final Rx<File?> regCertFrontImage = Rx<File?>(null);
  final Rx<File?> regCertBackImage = Rx<File?>(null);

  // Image URLs
  final RxString licensePlateImageUrl = ''.obs;
  final RxString regCertFrontImageUrl = ''.obs;
  final RxString regCertBackImageUrl = ''.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    carBrandTEController.dispose();
    carModelTEController.dispose();
    carYearTEController.dispose();
    licensePlateNumberTEController.dispose();
    registrationCertNumberTEController.dispose();
    super.onClose();
  }

  // ==================== Image Selection ====================
  Future<void> uploadAndSelectLicensePlateImage(File image) async {
    try {
      isLicensePlateImageUploading.value = true;
      licensePlateImage.value = image;
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
          licensePlateImageUrl.value = data[0];
        } else {
          errorMessage.value = 'Failed to get image URL from response';
          AppSnackbar.error(
            AppLocalization.tr.uploadFailedTitle,
            AppLocalization.tr.imageUrlMissingMessage,
          );
        }
      } else {
        debugPrint('car_information_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.uploadFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('car_information_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isLicensePlateImageUploading.value = false;
    }
  }

  Future<void> uploadAndSelectRegCertFrontImage(File image) async {
    try {
      isRegCertFrontImageUploading.value = true;
      regCertFrontImage.value = image;
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
          regCertFrontImageUrl.value = data[0];
        } else {
          errorMessage.value = 'Failed to get image URL from response';
          AppSnackbar.error(
            AppLocalization.tr.uploadFailedTitle,
            AppLocalization.tr.imageUrlMissingMessage,
          );
        }
      } else {
        debugPrint('car_information_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.uploadFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('car_information_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isRegCertFrontImageUploading.value = false;
    }
  }

  Future<void> uploadAndSelectRegCertBackImage(File image) async {
    try {
      isRegCertBackImageUploading.value = true;
      regCertBackImage.value = image;
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
          regCertBackImageUrl.value = data[0];
        } else {
          errorMessage.value = 'Failed to get image URL from response';
          AppSnackbar.error(
            AppLocalization.tr.uploadFailedTitle,
            AppLocalization.tr.imageUrlMissingMessage,
          );
        }
      } else {
        debugPrint('car_information_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.uploadFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('car_information_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isRegCertBackImageUploading.value = false;
    }
  }

  // ==================== Business Logic ====================
  Future<void> submitCarInfo() async {
    if (!validateCarDetails()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: Implement actual car info submission API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to next screen
      // Get.toNamed(AppRoutes.uploadProfilePictureScreen);
    } catch (e) {
      debugPrint('car_information_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Validation ====================
  bool validateCarDetails() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Returns `null` when this section is complete, otherwise the reason why not.
  ///
  /// Delegates to the same per-field validators the text fields use, so the
  /// red text under a field and the message on Submit can never disagree.
  String? validateSection() {
    return validateCarName(carBrandTEController.text) ??
        validateCarModel(carModelTEController.text) ??
        validateCarYear(carYearTEController.text) ??
        validateLicensePlate(licensePlateNumberTEController.text) ??
        validateRegistrationCertNumber(
          registrationCertNumberTEController.text,
        ) ??
        _validateImages();
  }

  /// Image rules live outside [validateSection]'s field checks because no
  /// single text field can express them.
  String? _validateImages() {
    if (isLicensePlateImageUploading.value ||
        isRegCertFrontImageUploading.value ||
        isRegCertBackImageUploading.value) {
      return AppLocalization.tr.carImagesUploadingMessage;
    }
    if (licensePlateImageUrl.value.isEmpty) {
      return AppLocalization.tr.uploadLicensePlateRequiredMessage;
    }
    if (regCertFrontImageUrl.value.isEmpty ||
        regCertBackImageUrl.value.isEmpty) {
      return AppLocalization.tr.uploadRegistrationCertBothSidesMessage;
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

  /// Re-syncs the documents-list status with what is actually in the form.
  ///
  /// Called when the user leaves the screen without pressing Submit. Unlike
  /// [saveSection] it stays silent: the user did not ask to submit, so an
  /// incomplete form is not an error worth interrupting them over - but the
  /// checkmark on the list must still tell the truth.
  void refreshSectionStatus() {
    isUploaded.value = validateSection() == null;
  }

  String? validateCarName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalization.tr.carNameRequiredError;
    }
    return null;
  }

  String? validateCarModel(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalization.tr.carModelRequiredError;
    }
    return null;
  }

  String? validateLicensePlate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalization.tr.numberPlateRequiredError;
    }
    return null;
  }

  String? validateRegistrationCertNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalization.tr.registrationCertNumberRequiredError;
    }
    return null;
  }

  String? validateCarNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.carNumberRequiredError;
    }
    return null;
  }

  String? validateCarColor(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalization.tr.carColorRequiredError;
    }
    return null;
  }

  String? validateCarYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return AppLocalization.tr.yearOfManufactureRequiredError;
    }
    final year = int.tryParse(text);
    if (year == null) {
      return AppLocalization.tr.invalidYearOfManufactureError;
    }
    // Allow next year so a brand-new model year is not rejected.
    final maxYear = DateTime.now().year + 1;
    if (year < 1900 || year > maxYear) {
      return AppLocalization.tr.invalidYearRangeError('$maxYear');
    }
    return null;
  }

  // ==================== Navigation ====================
  void goBack() {
    // Get.back();
  }
}
