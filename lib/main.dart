import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:ride_sharing/app.dart';
import 'package:ride_sharing/firebase_options.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Every screen is laid out for portrait; locking it prevents the cropped
  // controls App Review saw when the app was rotated.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Google Maps to use Hybrid Composition on Android
  _initializeMapRenderer();

  // Load saved locale before runApp so GetMaterialApp builds with correct language
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('locale') ?? 'fr';
  Get.updateLocale(Locale(savedLocale));

  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Initialize Stripe with publishable key
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Get.putAsync<SocketIoService>(() async {
    final service = SocketIoService();
    await service.init();
    return service;
  });

  runApp(const RideSharingApp());
}

void _initializeMapRenderer() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
}
