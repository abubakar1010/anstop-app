import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/my_ride/data/get_my_ride_response.dart';
import 'package:ride_sharing/feature/passenger/my_ride/service/my_ride_service.dart';
import 'package:ride_sharing/services/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

/// The driver's "My trips": the rides this user drove, split into ongoing
/// and completed.
class MyTripController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<MyRideModel> trips = <MyRideModel>[].obs;
  final RxString errorMessage = ''.obs;

  /// true = ongoing tab, false = completed tab.
  final RxBool isOngoing = true.obs;

  final MyRideService _service = MyRideService();

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadTrips();
  }

  // ==================== Business Logic ====================
  Future<void> loadTrips() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();
      final userId = prefs.getString('userId') ?? '';

      final response = await _service.getMyRides(accessToken: accessToken!);

      if (response.isSuccess) {
        final List list = response.responseData['data'] ?? [];
        final driven = list
            .map((e) => MyRideModel.fromJson(e))
            // A rider-and-driver account also gets the rides it took as a rider.
            .where((trip) => trip.driver.id == userId)
            .where((trip) => isOngoing.value ? trip.isOngoing : trip.isCompleted);
        trips.assignAll(MyRideModel.newestFirst(driven));
      } else {
        debugPrint('my_trip_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
      }
    } catch (e) {
      debugPrint('my_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  /// Called directly from the UI toggle.
  void onToggleChanged(bool value) {
    isOngoing.value = value;
    loadTrips();
  }
}
