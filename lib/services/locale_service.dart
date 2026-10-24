import 'package:ride_sharing/services/session_controller.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'api_client.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_urls.dart';
import 'socket_services.dart';

/// Single owner of the app's language choice.
///
/// Both language switchers (the splash-screen toggle and Settings) go through
/// here, so applying the locale and persisting it can never drift apart - a
/// change that updates the UI but forgets to save looks fine until the next
/// cold start, which is exactly the bug this replaces.
///
/// The server writes its messages, push notifications and emails in the
/// user's language too, so every change is also passed on to it: requests
/// carry it as Accept-Language (see ApiClient), the socket is told directly,
/// and the account's saved preference is updated for messages sent while the
/// app is closed.
class LocaleService {
  const LocaleService._();

  /// SharedPreferences key. [main] reads this before `runApp` to restore the
  /// last choice.
  static const String storageKey = 'locale';

  /// Used when there is no saved choice and the device language is neither
  /// French nor English, and whenever a stored value is unrecognised.
  static const Locale defaultLocale = Locale('fr');

  static const List<Locale> supportedLocales = [Locale('fr'), Locale('en')];

  /// Applies [locale] immediately and remembers it for the next launch.
  static Future<void> setLocale(Locale locale) async {
    Get.updateLocale(locale);
    await _applyToDependencies(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, locale.languageCode);

    if (Get.isRegistered<SocketIoService>()) {
      SocketIoService.to.setLanguage(locale.languageCode);
    }
    // Not awaited: the UI has already switched, and a failed save only means
    // the next push or email arrives in the old language until the next sync.
    syncToServer();
  }

  /// The stored choice; on first launch, the device language when it is
  /// supported; otherwise [defaultLocale].
  static Future<Locale> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(storageKey);
    if (saved != null) return _localeFor(saved);
    return _localeFor(PlatformDispatcher.instance.locale.languageCode);
  }

  /// Restores the saved locale into GetX. Call before `runApp`.
  static Future<void> restore() async {
    final locale = await loadSavedLocale();
    Get.updateLocale(locale);
    await _applyToDependencies(locale);
  }

  /// The active language code, "fr" or "en".
  static String get languageCode =>
      (Get.locale ?? defaultLocale).languageCode;

  /// Whether French is the active language.
  static bool get isFrench => languageCode == 'fr';

  /// Saves the active language on the signed-in user's account, so the server
  /// can write push notifications and emails in it. Call after sign-in and on
  /// launch with a saved session; does nothing when signed out.
  static Future<void> syncToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = await SessionController.to.accessToken();
      if (accessToken == null || accessToken.isEmpty) return;

      await ApiClient().postRequest(ApiUrls.setLanguagePreference,
          body: {'languagePreference': languageCode});
    } catch (e) {
      debugPrint('Language preference sync failed: $e');
    }
  }

  /// Points the locale-dependent libraries at [locale]: intl's default for
  /// DateFormat/NumberFormat, and the native geocoder used for addresses.
  static Future<void> _applyToDependencies(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    await initializeDateFormatting(locale.languageCode);
    try {
      await setLocaleIdentifier(
        locale.languageCode == 'fr' ? 'fr_FR' : 'en_US',
      );
    } catch (e) {
      // Not supported on every platform (e.g. web); addresses then follow the
      // device language.
      debugPrint('Geocoding locale not set: $e');
    }
  }

  /// Maps a language code onto a supported locale, falling back to
  /// [defaultLocale] rather than handing GetX a locale with no translations.
  static Locale _localeFor(String? languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => defaultLocale,
    );
  }
}
