import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing/routes/app_routes.dart';

/// Whether the app is in rider or driver mode. Pages shared by both roles
/// (notifications, support, settings) use it to show the right drawer.
///
/// Each home screen sets it when it opens, so it follows "Switch to drive" /
/// "Switch to ride" without every switch having to remember it.
class AppMode {
  AppMode._();

  static const _key = 'appModeIsDriver';
  static final RxBool isDriver = false.obs;

  static String get homeRoute =>
      isDriver.value ? AppRoutes.driverHomeScreen : AppRoutes.passengerHomeScreen;

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    isDriver.value = prefs.getBool(_key) ?? false;
  }

  static Future<void> set({required bool driver}) async {
    if (isDriver.value == driver) return;
    isDriver.value = driver;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, driver);
  }
}
