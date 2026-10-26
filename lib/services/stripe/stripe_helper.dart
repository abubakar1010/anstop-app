import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ride_sharing/services/stripe/payment_result.dart';
import 'package:ride_sharing/services/stripe/stripe_config.dart';
import 'package:ride_sharing/services/stripe/stripe_exeption.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

/// Robust Stripe Payment Helper Class
class StripePaymentHelper {
  final StripeConfig _config;
  Map<String, dynamic>? _currentPaymentData;

  // Callbacks for different payment events
  Function(PaymentResult)? onPaymentSuccess;
  Function(PaymentResult)? onPaymentFailure;
  Function(String)? onLog;

  StripePaymentHelper({
    required StripeConfig config,
    this.onPaymentSuccess,
    this.onPaymentFailure,
    this.onLog,
  }) : _config = config;

  /// Logs messages using the provided callback or default print
  void _log(String message) {
    if (onLog != null) {
      onLog!(message);
    } else {
      print('[StripePaymentHelper] $message');
    }
  }

  /// Initializes the payment sheet
  Future<void> _initializePaymentSheet(Map<String, dynamic> paymentData) async {
    try {
      final clientSecret = paymentData['client_secret'];
      if (clientSecret == null) {
        throw StripePaymentException('Missing client_secret in payment data');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: _config.merchantDisplayName,
          style: _config.paymentSheetTheme,
          allowsDelayedPaymentMethods: _config.allowsDelayedPaymentMethods,
        ),
      );

      _log('Payment sheet initialized successfully');
    } catch (e) {
      _log('Error initializing payment sheet: $e');
      // Shown to the user, so keep it translated; the cause is logged above.
      throw StripePaymentException(
        AppLocalization.tr.paymentFailedMessage,
        originalError: e,
      );
    }
  }

  /// Presents the payment sheet to the user
  Future<PaymentResult> _presentPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      _log('Payment completed successfully');

      final result = PaymentResult.success(paymentData: _currentPaymentData);

      // Clear current payment data
      _currentPaymentData = null;

      // Call success callback
      onPaymentSuccess?.call(result);

      return result;
    } on StripeException catch (e) {
      _log('Stripe error during payment: ${e.error}');

      final result = PaymentResult.failure(
        message: e.error.localizedMessage ?? AppLocalization.tr.paymentFailedMessage,
        errorCode: e.error.code?.name,
      );

      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, result.message!);
      }

      // Call failure callback
      onPaymentFailure?.call(result);

      return result;
    } catch (e) {
      _log('General error during payment: $e');

      final result = PaymentResult.failure(
        message: AppLocalization.tr.paymentUnexpectedErrorMessage,
      );

      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, result.message!);
      }

      // Call failure callback
      onPaymentFailure?.call(result);

      return result;
    }
  }

  /// Shows an error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalization.tr.paymentErrorTitle),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalization.tr.closeButton),
              ),
            ],
          ),
    );
  }

  /// Shows a success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalization.tr.paymentSuccessfulTitle),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalization.tr.closeButton),
              ),
            ],
          ),
    );
  }

  /// Main method to process a payment
  ///
  /// [context] - BuildContext for showing dialogs
  /// [clientSecret] - PaymentIntent client secret created by our server
  /// [showSuccessDialog] - Whether to show success dialog (default: true)
  Future<PaymentResult> processPayment({
    required BuildContext context,
    required String clientSecret,
    bool showSuccessDialog = true,
  }) async {
    try {
      if (clientSecret.isEmpty) {
        throw StripePaymentException('Missing client_secret in payment data');
      }

      _log('Starting payment process');

      // Step 1: Initialize payment sheet with the server-created intent
      _currentPaymentData = {'client_secret': clientSecret};
      await _initializePaymentSheet(_currentPaymentData!);

      // Step 2: Present payment sheet and handle result
      final result = await _presentPaymentSheet(context);

      // Show success dialog if payment was successful and requested
      if (result.isSuccess && showSuccessDialog && context.mounted) {
        // _showSuccessDialog(context, result.message!);
        _log(result.message!);
      }

      return result;
    } on StripePaymentException catch (e) {
      _log('Stripe payment exception: ${e.message}');

      final result = PaymentResult.failure(
        message: e.message,
        errorCode: e.errorCode,
      );

      // Show error dialog
      if (context.mounted) {
        _showErrorDialog(context, result.message!);
      }

      onPaymentFailure?.call(result);
      return result;
    } catch (e) {
      _log('Unexpected error during payment process: $e');

      final result = PaymentResult.failure(
        message: AppLocalization.tr.paymentUnexpectedErrorMessage,
      );

      onPaymentFailure?.call(result);
      return result;
    }
  }

  /// Updates the configuration
  void updateConfig(StripeConfig newConfig) {
    // Note: In a real implementation, you might want to make _config mutable
    // or create a new instance of StripePaymentHelper
    throw UnimplementedError('Config updates require creating a new instance');
  }

  /// Clears any cached payment data
  void clearPaymentData() {
    _currentPaymentData = null;
    _log('Payment data cleared');
  }
}
