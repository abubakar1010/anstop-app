import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_sharing/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/feature/driver/profile/service/driver_profile_service.dart';
import 'package:ride_sharing/feature/driver/profile/data/user_profile_model.dart';
import 'package:ride_sharing/feature/auth/service/auth_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class EditDriverProfileController extends GetxController {
  // ==================== Services ====================
  final DriverProfileService _profileService = DriverProfileService();
  final AuthService _authService = AuthService();

  // ==================== Text Controllers ====================
  final TextEditingController firstNameTEController = TextEditingController();
  final TextEditingController lastNameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController addressTEController = TextEditingController();
  DriverProfileController profileController = Get.put(DriverProfileController());
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString profilePictureUrl = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  // ==================== Image Picker ====================
  final ImagePicker _imagePicker = ImagePicker();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onClose() {
    firstNameTEController.dispose();
    lastNameTEController.dispose();
    emailTEController.dispose();
    addressTEController.dispose();
    super.onClose();
  }

  // ==================== Business Logic ====================
  void _loadInitialData() {
    final args = Get.arguments as UserProfileData?;
    if (args != null) {
      firstNameTEController.text = args.firstName;
      lastNameTEController.text = args.lastName;
      emailTEController.text = args.email;
      addressTEController.text = args.address ?? '';
      profilePictureUrl.value = args.profilePicture ?? '';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.imagePickFailedMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        errorMessage.value = AppLocalization.tr.sessionExpiredMessage;
        return;
      }

      String? uploadedImageUrl;

      // Upload image if a new one was selected
      if (selectedImage.value != null) {
        final uploadResponse = await _authService.uploadFiles(
          accessToken: accessToken,
          files: [selectedImage.value!],
        );

        if (uploadResponse.isSuccess && uploadResponse.responseData != null) {
          final data = uploadResponse.responseData['data'];
          if (data != null && data is List && data.isNotEmpty) {
            uploadedImageUrl = data[0];
          }
        } else {
          Get.snackbar(
            AppLocalization.tr.errorTitle,
            AppLocalization.tr.imageUploadFailedMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Build request body with only changed fields
      final Map<String, dynamic> body = {};

      if (firstNameTEController.text.isNotEmpty) {
        body['firstName'] = firstNameTEController.text.trim();
      }
      if (lastNameTEController.text.isNotEmpty) {
        body['lastName'] = lastNameTEController.text.trim();
      }
      if (emailTEController.text.isNotEmpty) {
        body['email'] = emailTEController.text.trim();
      }
      if (addressTEController.text.isNotEmpty) {
        body['address'] = addressTEController.text.trim();
      }
      if (uploadedImageUrl != null) {
        body['profilePicture'] = uploadedImageUrl;
      }

      if (body.isEmpty) {
        Get.snackbar(
          AppLocalization.tr.infoTitle,
          AppLocalization.tr.noChangesToSaveMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await _profileService.updateProfile(
        accessToken: accessToken,
        body: body,
      );

      if (response.isSuccess) {
        // Get.snackbar(
        //   'Success',
        //   'Profile updated successfully',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
         profileController.loadProfile();
         Get.toNamed(AppRoutes.driverProfileScreen);
        // Navigate back and refresh profile
      } else {
        debugPrint('edit_driver_profile_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('edit_driver_profile_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.genericErrorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
