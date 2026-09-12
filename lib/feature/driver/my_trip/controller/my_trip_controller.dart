import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:flutter/foundation.dart';

class MyTripController extends GetxController {
  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<dynamic> trips = <dynamic>[].obs;
  final RxInt selectedTab = 0.obs; // 0: All, 1: Completed, 2: Cancelled
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;

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

      // TODO: Implement actual API call to load trips
      await Future.delayed(const Duration(seconds: 1));

      // For now, just set empty list
      trips.value = [];
      hasMore.value = false;

    } catch (e) {
      debugPrint('my_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTrips() async {
    selectedTab.value = 0;
    await loadTrips();
  }

  void filterTrips(int tabIndex) {
    selectedTab.value = tabIndex;
    loadTrips();
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;

    try {
      isLoading.value = true;

      // TODO: Implement pagination
      await Future.delayed(const Duration(seconds: 1));

    } catch (e) {
      debugPrint('my_trip_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToTripDetails(dynamic trip) {
    // TODO: Navigate to trip details based on trip status
    // if (trip.status == 'ongoing') {
    //   Get.toNamed(AppRoutes.driverOngoingTripScreen, arguments: trip);
    // } else {
    //   Get.toNamed(AppRoutes.driverCompletedTripScreen, arguments: trip);
    // }
  }
}
