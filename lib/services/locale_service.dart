import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single owner of the app's language choice.
///
/// Both language switchers (the splash-screen toggle and Settings) go through
/// here, so applying the locale and persisting it can never drift apart - a
/// change that updates the UI but forgets to save looks fine until the next
/// cold start, which is exactly the bug this replaces.
class LocaleService {
  const LocaleService._();

  /// SharedPreferences key. [main] reads this before `runApp` to restore the
  /// last choice.
  static const String storageKey = 'locale';

  /// Used for a fresh install, and whenever a stored value is unrecognised.
  static const Locale defaultLocale = Locale('fr');

  static const List<Locale> supportedLocales = [Locale('fr')];

  /// Applies [locale] immediately and remembers it for the next launch.
  static Future<void> setLocale(Locale locale) async {
    Get.updateLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, locale.languageCode);
  }

  /// The stored choice, or [defaultLocale] when there is none.
  static Future<Locale> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return _localeFor(prefs.getString(storageKey));
  }

  /// Restores the saved locale into GetX. Call before `runApp`.
  static Future<void> restore() async {
    // Always force French since it is the only supported language.
    Get.updateLocale(defaultLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, defaultLocale.languageCode);
  }

  /// Whether French is currently active — always true now.
  static bool get isFrench => true;

  /// Maps a stored language code onto a supported locale, falling back to
  /// [defaultLocale] rather than handing GetX a locale with no translations.
  static Locale _localeFor(String? languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => defaultLocale,
    );
  }
}
