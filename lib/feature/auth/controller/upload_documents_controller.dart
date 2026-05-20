import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/auth/controller/car_information_controller.dart';
import 'package:ride_sharing/feature/auth/controller/driving_license_controller.dart';
import 'package:ride_sharing/feature/auth/controller/national_id_controller.dart';
import 'package:ride_sharing/feature/auth/controller/upload_profile_picture_controller.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadDocumentsController extends GetxController {
  // ==================== Services ====================
  final AuthService _authService = AuthService();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isNationalIdUploaded = false.obs;
  final RxBool isDrivingLicenseUploaded = false.obs;
  final RxString errorMessage = ''.obs;

  // Profile data from registration screen
  // String? gender;
  String? address;
  String? dateOfBirth;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    // Get data from navigation arguments if passed
    if (Get.arguments != null && Get.arguments is Map) {
      // gender = Get.arguments['gender'];
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

  void markDocumentUploaded(String documentType, bool uploaded) {
    switch (documentType) {
      case 'national_id':
        isNationalIdUploaded.value = uploaded;
        break;
      case 'driving_license':
        isDrivingLicenseUploaded.value = uploaded;
        break;
      default:
        break;
    }
  }

  bool checkCompletion() {
    return isNationalIdUploaded.value && isDrivingLicenseUploaded.value;
  }

  // ==================== Onboard API ====================
  Future<void> submitDriverOnboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get access token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token not found. Please login again.';
        Get.snackbar(
          'Error',
          'Access token not found. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
        // 'gender': gender ?? 'MALE',
        'address': address ?? '',
        'dateOfBirth': dateOfBirth ?? '',
      };

      // Call the onboard API with URLs (not files)
      final response = await _authService.driverOnboard(
        accessToken: accessToken,
        jsonBody: jsonBody,
      );

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          'Driver onboarding completed successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to driver home screen
        Get.offAllNamed(AppRoutes.driverHomeScreen);
      } else {
        errorMessage.value = response.errorMessage;
        Get.snackbar(
          'Onboarding Failed',
          response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Failed to complete onboarding. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    // Validate National ID
    if (nationalIdController.nidNumberTEController.text.trim().isEmpty) {
      errorMessage.value = 'National ID number is required';
      _showErrorSnackbar('National ID number is required');
      return false;
    }
    if (nationalIdController.frontImageUrl.value.isEmpty ||
        nationalIdController.backImageUrl.value.isEmpty) {
      errorMessage.value = 'Please upload both front and back of National ID';
      _showErrorSnackbar('Please upload both front and back of National ID');
      return false;
    }

    // Validate Driving License
    if (drivingLicenseController.licenseNumberTEController.text
        .trim()
        .isEmpty) {
      errorMessage.value = 'Driving license number is required';
      _showErrorSnackbar('Driving license number is required');
      return false;
    }
    if (drivingLicenseController.frontImageUrl.value.isEmpty ||
        drivingLicenseController.backImageUrl.value.isEmpty) {
      errorMessage.value =
          'Please upload both front and back of Driving License';
      _showErrorSnackbar(
        'Please upload both front and back of Driving License',
      );
      return false;
    }

    // Validate Car Information
    if (carInfoController.carBrandTEController.text.trim().isEmpty) {
      errorMessage.value = 'Car brand is required';
      _showErrorSnackbar('Car brand is required');
      return false;
    }
    if (carInfoController.carModelTEController.text.trim().isEmpty) {
      errorMessage.value = 'Car model is required';
      _showErrorSnackbar('Car model is required');
      return false;
    }
    if (carInfoController.carYearTEController.text.trim().isEmpty) {
      errorMessage.value = 'Year of manufacture is required';
      _showErrorSnackbar('Year of manufacture is required');
      return false;
    }
    if (carInfoController.licensePlateNumberTEController.text.trim().isEmpty) {
      errorMessage.value = 'License plate number is required';
      _showErrorSnackbar('License plate number is required');
      return false;
    }
    if (carInfoController.licensePlateImageUrl.value.isEmpty) {
      errorMessage.value = 'Please upload license plate picture';
      _showErrorSnackbar('Please upload license plate picture');
      return false;
    }
    if (carInfoController.registrationCertNumberTEController.text
        .trim()
        .isEmpty) {
      errorMessage.value = 'Registration certificate number is required';
      _showErrorSnackbar('Registration certificate number is required');
      return false;
    }
    if (carInfoController.regCertFrontImageUrl.value.isEmpty ||
        carInfoController.regCertBackImageUrl.value.isEmpty) {
      errorMessage.value =
          'Please upload both front and back of Registration Certificate';
      _showErrorSnackbar(
        'Please upload both front and back of Registration Certificate',
      );
      return false;
    }

    // Validate Profile Picture
    if (profilePictureController.profileImageUrl.value.isEmpty) {
      errorMessage.value = 'Please upload profile picture';
      _showErrorSnackbar('Please upload profile picture');
      return false;
    }

    // Validate profile data
    // if (gender == null || gender!.isEmpty) {
    //   errorMessage.value = 'Gender is required';
    //   _showErrorSnackbar('Gender is required');
    //   return false;
    // }
    if (address == null || address!.isEmpty) {
      errorMessage.value = 'Address is required';
      _showErrorSnackbar('Address is required');
      return false;
    }
    if (dateOfBirth == null || dateOfBirth!.isEmpty) {
      errorMessage.value = 'Date of birth is required';
      _showErrorSnackbar('Date of birth is required');
      return false;
    }

    return true;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // ==================== Navigation ====================
  void goBack() {
    Get.back();
  }

  void skipDocuments() {
    // Get.toNamed(AppRoutes.carInformationScreen);
  }
}
