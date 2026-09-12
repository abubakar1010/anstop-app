import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration sourced from the bundled `.env` asset.
///
/// Keys live here rather than in source so they are not committed. `.env` is
/// loaded in `main()` before `runApp`, so every getter below is safe to read
/// from anywhere in the app.
class AppConfig {
  const AppConfig._();

  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
}
