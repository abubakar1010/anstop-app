import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

/// Single entry point for snackbars. Never call `Get.snackbar` directly.
///
/// GetX 4.7.x's snackbar queue (`GetQueue`) only catches `Exception`. Any
/// `Error` raised while a snackbar is shown or closed - "No Overlay widget
/// found", a `LateInitializationError` on its `AnimationController`, a failed
/// assert - escapes the queue with `_active` still set. From then on:
///
///  * no snackbar is ever displayed again until the app restarts, so every
///    validation and upload error becomes a silent no-op; and
///  * the dead job stays in GetX's list, so `Get.isSnackbarOpen` is stuck at
///    true and every `Get.back()` tries to close it instead of popping - which
///    is how loading dialogs ended up stuck on screen.
///
/// So snackbars are shown with Flutter's own [ScaffoldMessenger] instead, via
/// [messengerKey] (wired into `GetMaterialApp` in app.dart), and GetX's
/// snackbar machinery is never touched.
class AppSnackbar {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    // Kept so call sites read the same as before; ScaffoldMessenger always
    // shows snackbars at the bottom, which is all the app ever used.
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) {
      // The very first frame is still being built; try again once it is.
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => show(
          title: title,
          message: message,
          backgroundColor: backgroundColor,
          colorText: colorText,
          duration: duration,
        ),
      );
      return;
    }

    final textColor = colorText ?? Colors.white;
    // Replace whatever is currently on screen rather than waiting it out.
    // Tapping a Submit button twice must show the second message straight
    // away - queueing behind the first one makes the button look unresponsive.
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          duration: duration,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
              if (message.isNotEmpty)
                Text(message, style: TextStyle(color: textColor)),
            ],
          ),
        ),
      );
  }

  /// Drop-in replacement for `Get.snackbar(title, message, ...)`.
  static void snackbar(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      colorText: colorText,
      snackPosition: snackPosition,
      duration: duration,
    );
  }

  /// Closes any visible snackbar.
  ///
  /// Call this before popping a route that may have shown a snackbar.
  static Future<void> dismiss() async {
    messengerKey.currentState?.clearSnackBars();
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
