import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ride_sharing/services/locale_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:ride_sharing/app.dart';
import 'package:ride_sharing/firebase_options.dart';
import 'package:ride_sharing/services/location_service.dart';
import 'package:ride_sharing/services/socket_services.dart';
import 'package:ride_sharing/services/session_controller.dart';
import 'package:ride_sharing/services/realtime_client.dart';
import 'package:ride_sharing/services/ride_session_controller.dart';
import 'package:ride_sharing/services/notification_badge_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Every screen is laid out for portrait; locking it prevents the cropped
  // controls App Review saw when the app was rotated.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Google Maps to use Hybrid Composition on Android
  _initializeMapRenderer();

  // Load saved locale before runApp so GetMaterialApp builds with correct language
  await LocaleService.restore();

  // Restore the last known position before runApp so the first map frame opens
  // where the user actually is instead of a hardcoded city.
  await LocationService.warmUp();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Initialize Stripe with publishable key
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final session = Get.put(SessionController(), permanent: true);
  await session.restore();
  await Get.putAsync<SocketIoService>(() async {
    final service = SocketIoService();
    await service.init();
    return service;
  });
  Get.put(RealtimeClient(), permanent: true);
  Get.put(RideSessionController().initialize(), permanent: true);
  Get.put(NotificationBadgeService().initialize(), permanent: true);

  runApp(const RideSharingApp());
}

void _initializeMapRenderer() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
}
