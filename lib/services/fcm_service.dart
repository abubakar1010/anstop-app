import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ride_sharing/services/api_urls.dart';
import 'package:logger/logger.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Logger _logger = Logger(); // ✅ Logger instance

  /// Guards the [onTokenRefresh] subscription. A new FcmService is constructed
  /// per controller, so without a static guard every sign-in would attach
  /// another listener and re-POST the token once per past login.
  static StreamSubscription<String>? _refreshSubscription;

  /// Registers this device for push.
  ///
  /// Never throws: push registration must not be able to block sign-in. Every
  /// failure path here (permission denied, no APNS token, API unreachable)
  /// leaves the caller free to continue.
  Future<void> initFCM({required String accessToken}) async {
    try {
      // 🔔 Request permission
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // On Apple platforms `getToken()` throws `apns-token-not-set` until APNS
      // has handed us its token. That happens asynchronously after permission
      // is granted, and on the Simulator it never happens at all.
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        if (await _waitForApnsToken() == null) {
          _logger.w(
            '⚠️ No APNS token available - skipping FCM registration. '
            'This is expected on the iOS Simulator.',
          );
          return;
        }
      }

      // 🔑 Get FCM token
      final token = await _messaging.getToken();

      if (token != null) {
        _logger.i('🟢 Generated FCM Token: $token'); // log generated token
        await _sendFcmTokenToApi(
          fcmToken: token,
          accessToken: accessToken,
        );
      }

      // 🔄 Handle token refresh
      await _refreshSubscription?.cancel();
      _refreshSubscription = _messaging.onTokenRefresh.listen((newToken) async {
        _logger.i('♻️ FCM Token refreshed: $newToken'); // log refreshed token
        await _sendFcmTokenToApi(
          fcmToken: newToken,
          accessToken: accessToken,
        );
      });
    } catch (e) {
      _logger.e('❌ FCM init failed (non-fatal): $e');
    }
  }

  /// Polls for the APNS token until it arrives or [timeout] elapses.
  /// Returns null if it never does.
  Future<String?> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return apnsToken;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }

  Future<void> _sendFcmTokenToApi({
    required String fcmToken,
    required String accessToken,
  }) async {
    try {
      _logger.i('➡️ Sending FCM token to API: $fcmToken'); // log token being sent

      final response = await http.post(
        Uri.parse(ApiUrls.setFcmToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ FCM token sent successfully to API');
      } else {
        _logger.w('❌ Failed to send FCM token: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ FCM API ERROR: $e');
    }
  }
}
