import 'package:ride_sharing/services/session_controller.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/passenger/my_ride/data/get_my_ride_response.dart';
import 'package:ride_sharing/feature/passenger/my_ride/service/my_ride_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

class MyRideController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<MyRideModel> rides = <MyRideModel>[].obs;
  final RxInt selectedTab = 0.obs; // 0: All, 1: Completed, 2: Cancelled
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

  final MyRideService _service = MyRideService();

  /// 0 = ON_GOING , 1 = COMPLETED
  final RxBool isOngoing = true.obs;
  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    loadRides();
  }

  // ==================== Business Logic ====================
  Future<void> loadRides() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();
      final userId = prefs.getString('userId') ?? '';

      // One request for every status: "ongoing" spans several of them, and
      // finished rides end as PAID, not COMPLETED.
      final response = await _service.getMyRides(accessToken: accessToken!);

      if (response.isSuccess) {
        final List list = response.responseData['data'] ?? [];
        final mine = list
            .map((e) => MyRideModel.fromJson(e))
            // A rider-and-driver account also gets the rides it drove.
            .where((ride) => ride.rider.id == userId)
            .where((ride) => isOngoing.value ? ride.isOngoing : ride.isCompleted);
        rides.assignAll(MyRideModel.newestFirst(mine));
      }
      else {
        debugPrint('my_ride_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
      }
    } catch (e) {
      debugPrint('my_ride_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  /// Called directly from UI toggle
  void onToggleChanged(bool value) {
    isOngoing.value = value;
    loadRides();
  }

  Future<void> refreshRides() async {
    selectedTab.value = 0;
    await loadRides();
  }

  void filterRides(int tabIndex) {
    selectedTab.value = tabIndex;
    loadRides();
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;

    try {
      isLoading.value = true;

      // TODO: Implement pagination
      await Future.delayed(const Duration(seconds: 1));

    } catch (e) {
      debugPrint('my_ride_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRideDetails(dynamic ride) {
    // TODO: Navigate to ride details
    // Get.toNamed(AppRoutes.passengerOngoingTripScreen, arguments: ride);
  }
}
