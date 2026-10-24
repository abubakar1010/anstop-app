// Configuration class for Stripe settings
import 'package:flutter/material.dart';

// No secret key here on purpose: anything in the app can be extracted from the
// APK. PaymentIntents are created by our server, which returns only the
// client secret the payment sheet needs.
class StripeConfig {
  final String merchantDisplayName;
  final ThemeMode paymentSheetTheme;
  final bool allowsDelayedPaymentMethods;

  const StripeConfig({
    this.merchantDisplayName = 'Your Business Name',
    this.paymentSheetTheme = ThemeMode.system,
    this.allowsDelayedPaymentMethods = true,
  });
}
