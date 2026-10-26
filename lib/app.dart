import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/theme/app_theme.dart';
import 'package:ride_sharing/app/utils/app_snackbar.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:ride_sharing/routes/app_routes.dart';
import 'package:ride_sharing/services/locale_service.dart';

class RideSharingApp extends StatelessWidget {
  const RideSharingApp({super.key});

  // flutter_screenutil scales every .w/.h/.sp value against [designSize].
  // That design size is tuned for phones, so on an iPad the width-based
  // scale factor balloons (~2x), making text/padding oversized and the
  // layout look crowded/overlapping. Use a tablet-sized design reference
  // on large screens so the scale factor stays close to 1.
  Size _designSizeForDevice() {
    final ui.FlutterView view = ui.PlatformDispatcher.instance.views.first;
    final Size logicalSize = view.physicalSize / view.devicePixelRatio;
    final bool isTablet = logicalSize.shortestSide >= 600;
    return isTablet ? const Size(834, 1194) : const Size(392, 852);
  }

  @override
  Widget build(BuildContext context) {
    bool isBottomNavigationVisible(BuildContext context) {
      final EdgeInsets padding = MediaQuery.of(context).viewInsets;
      return padding.bottom == 0.0;
    }
    return ScreenUtilInit(
      splitScreenMode: true,
      minTextAdapt: true,
      designSize: _designSizeForDevice(),
      builder: (_, _) {
        return GetMaterialApp(
          scaffoldMessengerKey: AppSnackbar.messengerKey,
          builder: (_, Widget? child) {
            final bool bottomNavigationVisible = isBottomNavigationVisible(context);
            return SafeArea(top: false, bottom: bottomNavigationVisible, child: child!);
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // No `locale:` here on purpose. GetMaterialApp assigns any non-null
          // value straight onto Get.locale in a one-shot initState that runs
          // *after* main() restored the saved choice, so passing one pins every
          // cold start to that language and silently discards the user's pick.
          fallbackLocale: LocaleService.defaultLocale,
          supportedLocales: LocaleService.supportedLocales,
        //  darkTheme: AppThemeData.darkThemeData,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashScreen, // Initial route
          getPages: AppRoutes.routes, // Your defined routes
          theme: AppThemeData.lightThemeData,
        );
      }
    );
  }
}
