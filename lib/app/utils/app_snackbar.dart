import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.overlayContext != null) {
      Get.snackbar(
        title,
        message,
        backgroundColor: backgroundColor,
        colorText: colorText,
        snackPosition: snackPosition,
        duration: duration,
      );
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (Get.overlayContext != null) {
          Get.snackbar(
            title,
            message,
            backgroundColor: backgroundColor,
            colorText: colorText,
            snackPosition: snackPosition,
            duration: duration,
          );
        }
      });
    }
  }

  static void success(String title, String message) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  static void error(String title, String message) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  static void warning(String title, String message) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }
}
