import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

/// Single entry point for snackbars.
///
/// Calling `Get.snackbar` directly is unsafe on GetX 4.7.x. `Get.snackbar`
/// appends the snackbar to an internal queue immediately, but the snackbar's
/// `AnimationController` is only created once it is actually displayed.
/// Meanwhile `Get.isSnackbarOpen` already reports true for the queued one, and
/// anything that closes it - `Get.closeCurrentSnackbar()`, or `Get.back()`,
/// which closes the open snackbar instead of popping - reaches for that
/// uninitialised controller and throws:
///
///     LateInitializationError: Field '_controller@...' has not been initialized.
///
/// This helper keeps at most one snackbar inside GetX's queue at a time, so a
/// queued-but-never-shown snackbar can never exist.
class AppSnackbar {
  /// Serialises callers so two snackbars are never handed to GetX at once.
  static Future<void> _pending = Future<void>.value();

  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    _pending = _pending.then(
      (_) => _display(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        colorText: colorText,
        snackPosition: snackPosition,
        duration: duration,
      ),
      // Never let one failed snackbar poison the chain and silence the rest.
      onError: (_) {},
    );
  }

  static Future<void> _display({
    required String title,
    required String message,
    required Color? backgroundColor,
    required Color? colorText,
    required SnackPosition snackPosition,
    required Duration duration,
  }) async {
    await _waitForOverlay();
    if (Get.overlayContext == null) return;

    try {
      // Replace whatever is currently on screen rather than waiting it out.
      // Tapping a Submit button twice must show the second message straight
      // away - queueing behind the first one's full display makes the button
      // look unresponsive.
      await dismiss();
      if (Get.overlayContext == null) return;

      Get.snackbar(
        title,
        message,
        backgroundColor: backgroundColor,
        colorText: colorText,
        snackPosition: snackPosition,
        duration: duration,
      );
      // Release the chain only once GetX has actually mounted this snackbar,
      // so its AnimationController exists before anyone can dismiss it.
      await _nextFrame();
    } catch (_) {
      // A snackbar is never worth crashing a screen over.
    }
  }

  /// Waits until GetX has an overlay to attach to (it has none while the very
  /// first frame is still being built).
  static Future<void> _waitForOverlay() async {
    if (Get.overlayContext != null) return;
    await _nextFrame();
  }

  static Future<void> _nextFrame() {
    final completer = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) => completer.complete());
    SchedulerBinding.instance.ensureVisualUpdate();
    return completer.future;
  }

  /// Closes any visible snackbar and waits until GetX's queue has actually
  /// drained.
  ///
  /// Awaiting `Get.closeCurrentSnackbar()` alone is not enough: `_SnackBarQueue`
  /// only removes the finished job from its list a microtask *after* the close
  /// future completes, so `Get.isSnackbarOpen` is still true when that await
  /// returns. Anything that reacts to `isSnackbarOpen` - notably `Get.back()`,
  /// which fires an unawaited `closeCurrentSnackbar()` on the dead controller -
  /// then throws an unhandled LateInitializationError.
  ///
  /// Call this before popping a route that may have shown a snackbar.
  static Future<void> dismiss() async {
    try {
      if (!Get.isSnackbarOpen) return;
      await Get.closeCurrentSnackbar();
      // Bounded drain, so a snackbar that never clears can't hang the caller.
      for (var i = 0; i < 20 && Get.isSnackbarOpen; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    } catch (_) {
      // A stuck snackbar must never block navigation.
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
