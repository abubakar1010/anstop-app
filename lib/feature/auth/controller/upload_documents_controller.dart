import 'package:ride_sharing/services/session_controller.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/feature/auth/controller/car_information_controller.dart';
import 'package:ride_sharing/feature/auth/controller/driving_license_controller.dart';
import 'package:ride_sharing/feature/auth/controller/national_id_controller.dart';
import 'package:ride_sharing/feature/auth/controller/upload_profile_picture_controller.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

class UploadDocumentsController extends GetxController {
  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Profile data from registration screen
  String? address;
  String? dateOfBirth;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    // Get data from navigation arguments if passed
    if (Get.arguments != null && Get.arguments is Map) {
      address = Get.arguments['address'];
      dateOfBirth = Get.arguments['dateOfBirth'];
    }
  }

  // ==================== Business Logic ====================
  void navigateToDocument(String documentType) {
    switch (documentType) {
      case 'national_id':
        Get.toNamed(AppRoutes.nationalIdScreen);
        break;
      case 'driving_license':
        Get.toNamed(AppRoutes.drivingLicenseScreen);
        break;
      case 'car_information':
        Get.toNamed(AppRoutes.carInformationScreen);
        break;
      case 'profile_picture':
        Get.toNamed(AppRoutes.uploadProfilePictureScreen);
        break;
      default:
        break;
    }
  }

  // ==================== Onboard API ====================
  Future<void> submitDriverOnboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get access token from shared preferences
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

      // Get controllers
      final nationalIdController = Get.find<NationalIdController>();
      final drivingLicenseController = Get.find<DrivingLicenseController>();
      final carInfoController = Get.find<CarInformationController>();
      final profilePictureController =
          Get.find<UploadProfilePictureController>();

      // Validate all required fields
      if (!_validateAllData(
        nationalIdController,
        drivingLicenseController,
        carInfoController,
        profilePictureController,
      )) {
        return;
      }

      // Prepare JSON body structure with image URLs
      final jsonBody = <String, dynamic>{
        'nid': {
          'number': nationalIdController.nidNumberTEController.text.trim(),
          'frontPicture': nationalIdController.frontImageUrl.value,
          'backPicture': nationalIdController.backImageUrl.value,
        },
        'drivingLicense': {
          'number': drivingLicenseController.licenseNumberTEController.text
              .trim(),
          'frontPicture': drivingLicenseController.frontImageUrl.value,
          'backPicture': drivingLicenseController.backImageUrl.value,
        },
        'carInformation': {
          'brand': carInfoController.carBrandTEController.text.trim(),
          'model': carInfoController.carModelTEController.text.trim(),
          'yearOfManufacture': carInfoController.carYearTEController.text
              .trim(),
          'licensePlate': {
            'number': carInfoController.licensePlateNumberTEController.text
                .trim(),
            'picture': carInfoController.licensePlateImageUrl.value,
          },
          'registrationCertificate': {
            'number': carInfoController.registrationCertNumberTEController.text
                .trim(),
            'frontPicture': carInfoController.regCertFrontImageUrl.value,
            'backPicture': carInfoController.regCertBackImageUrl.value,
          },
        },
        'profilePicture': profilePictureController.profileImageUrl.value,
        'address': address ?? '',
        'dateOfBirth': dateOfBirth ?? '',
      };

      // Call the onboard API with URLs (not files)
      final response = await _authService.driverOnboard(
        accessToken: accessToken,
        jsonBody: jsonBody,
      );

      if (response.isSuccess) {
        AppSnackbar.success(
          AppLocalization.tr.successTitle,
          AppLocalization.tr.driverOnboardingSuccessMessage,
        );

        // Review is a separate account state; do not open an active-only screen.
        await SessionController.to.loadAccount();
        Get.offAllNamed(SessionController.to.accountState.value == 'ACTIVE'
            ? AppRoutes.driverHomeScreen : AppRoutes.accountStatusScreen);
      } else {
        debugPrint('upload_documents_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        AppSnackbar.error(
          AppLocalization.tr.onboardingFailedTitle,
          AppLocalization.tr.genericErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('upload_documents_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      AppSnackbar.error(AppLocalization.tr.errorTitle, AppLocalization.tr.genericErrorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateAllData(
    NationalIdController nationalIdController,
    DrivingLicenseController drivingLicenseController,
    CarInformationController carInfoController,
    UploadProfilePictureController profilePictureController,
  ) {
    // Each section owns its own rules so the list status and the submit check
    // can never drift apart.
    final error =
        nationalIdController.validateSection() ??
        drivingLicenseController.validateSection() ??
        carInfoController.validateSection() ??
        profilePictureController.validateSection() ??
        _validateProfileData();

    if (error != null) {
      errorMessage.value = error;
      _showErrorSnackbar(error);
      return false;
    }
    return true;
  }

  String? _validateProfileData() {
    if (address == null || address!.trim().isEmpty) {
      return AppLocalization.tr.addressRequiredError;
    }
    if (dateOfBirth == null || dateOfBirth!.trim().isEmpty) {
      return AppLocalization.tr.dateOfBirthRequiredError;
    }
    return null;
  }

  void _showErrorSnackbar(String message) {
    AppSnackbar.error(AppLocalization.tr.validationErrorTitle, message);
  }

  // ==================== Navigation ====================
  void goBack() {
    Get.back();
  }
}
