import 'package:ride_sharing/services/session_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/feature/driver/profile/service/driver_profile_service.dart';
import 'package:ride_sharing/feature/driver/profile/data/user_profile_model.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

class DriverProfileController extends GetxController {
  // ==================== Services ====================
  final DriverProfileService _profileService = DriverProfileService();

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserProfileData?> profileData = Rx<UserProfileData?>(null);
  final RxBool isAccountInactive = false.obs;

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  // ==================== Business Logic ====================
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken() ?? '';

      if (accessToken.isEmpty) {
        errorMessage.value = AppLocalization.tr.sessionExpiredMessage;
        return;
      }

      final response = await _profileService.getMyProfile(accessToken: accessToken);

      if (response.isSuccess) {
        final profileResponse = UserProfileResponse.fromJson(response.responseData);
        profileData.value = profileResponse.data;
      } else {
        debugPrint('driver_profile_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        if (response.statusCode == 401) {
          isAccountInactive.value = true;
        }
      }
    } catch (e) {
      debugPrint('driver_profile_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }
}
