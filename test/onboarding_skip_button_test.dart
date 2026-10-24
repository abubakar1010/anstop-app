import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/splash_screen/onboarding_skip_button.dart';
import 'package:ride_sharing/l10n/app_localizations.dart';
import 'package:ride_sharing/routes/app_routes.dart';

void main() {
  testWidgets('Skip opens auth selection and removes onboarding', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        getPages: [
          GetPage(
            name: '/',
            page: () => const Scaffold(body: OnboardingSkipButton()),
          ),
          GetPage(
            name: AppRoutes.passengerAuthSelectionScreen,
            page: () => const Scaffold(body: Text('Auth selection')),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Auth selection'), findsOneWidget);
    expect(find.byType(OnboardingSkipButton), findsNothing);
    expect(Get.key.currentState!.canPop(), isFalse);
  });
}
