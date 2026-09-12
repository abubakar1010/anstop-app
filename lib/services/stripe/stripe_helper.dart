import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
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

  /// Validates payment parameters
  void _validatePaymentParams(double amount, String currency) {
    if (amount <= 0) {
      throw StripePaymentException('Amount must be greater than 0');
    }

    if (currency.isEmpty || currency.length != 3) {
      throw StripePaymentException(
        'Currency must be a valid 3-letter code (e.g., USD, EUR)',
      );
    }

    if (_config.secretKey.isEmpty || !_config.secretKey.startsWith('sk_')) {
      throw StripePaymentException('Invalid Stripe secret key');
    }
  }

  /// Creates a payment intent with Stripe API
  Future<Map<String, dynamic>> _createPaymentIntent({
    required double amount,
    required String currency,
    List<String> paymentMethodTypes = const ['card'],
    Map<String, dynamic>? metadata,
    String? customerId,
    String? description,
  }) async {
    try {
      // Convert amount to cents/smallest currency unit
      final int amountInCents = (amount * 100).round();

      // Prepare request body
      final Map<String, String> requestBody = {
        'amount': amountInCents.toString(),
        'currency': currency.toLowerCase(),
      };

      // Add optional parameters
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }

      if (customerId != null && customerId.isNotEmpty) {
        requestBody['customer'] = customerId;
      }

      // Choose between automatic_payment_methods or specific payment_method_types
      // Don't use both as Stripe doesn't allow it
      if (paymentMethodTypes.length == 1 && paymentMethodTypes[0] == 'card') {
        // Use automatic payment methods for better user experience with cards
        requestBody['automatic_payment_methods[enabled]'] = 'true';
      } else {
        // Use specific payment method types
        for (int i = 0; i < paymentMethodTypes.length; i++) {
          requestBody['payment_method_types[$i]'] = paymentMethodTypes[i];
        }
      }

      // Add metadata
      if (metadata != null) {
        metadata.forEach((key, value) {
          requestBody['metadata[$key]'] = value.toString();
        });
      }

      _log(
        'Creating payment intent for amount: \$${amount.toStringAsFixed(2)} $currency',
      );

      final response = await http.post(
        Uri.parse('${_config.baseUrl}/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${_config.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      _log('Payment intent API response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      _log('Payment intent API response body: $responseData');

      if (response.statusCode != 200) {
        final errorMessage =
            responseData['error']?['message'] ??
            'Unknown error creating payment intent';
        final errorCode = responseData['error']?['code'];
        throw StripePaymentException(
          errorMessage,
          errorCode: errorCode,
          originalError: responseData,
        );
      }

      return responseData;
    } catch (e) {
      if (e is StripePaymentException) {
        rethrow;
      }
      _log('Error creating payment intent: $e');
      throw StripePaymentException(
        'Failed to create payment intent: ${e.toString()}',
        originalError: e,
      );
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
      throw StripePaymentException(
        'Failed to initialize payment sheet: ${e.toString()}',
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
        message: e.error.localizedMessage ?? 'Payment failed',
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
  /// [amount] - Payment amount in dollars/euros/etc (will be converted to cents)
  /// [currency] - 3-letter currency code (e.g., 'USD', 'EUR')
  /// [description] - Optional payment description
  /// [customerId] - Optional Stripe customer ID
  /// [metadata] - Optional metadata to attach to the payment
  /// [showSuccessDialog] - Whether to show success dialog (default: true)
  /// [paymentMethodTypes] - List of allowed payment method types
  Future<PaymentResult> processPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    String? description,
    String? customerId,
    Map<String, dynamic>? metadata,
    bool showSuccessDialog = true,
    List<String> paymentMethodTypes = const ['card'],
  }) async {
    try {
      // Validate parameters
      _validatePaymentParams(amount, currency);

      _log(
        'Starting payment process for \$${amount.toStringAsFixed(2)} $currency',
      );

      // Step 1: Create payment intent
      _currentPaymentData = await _createPaymentIntent(
        amount: amount,
        currency: currency,
        description: description,
        customerId: customerId,
        metadata: metadata,
        paymentMethodTypes: paymentMethodTypes,
      );

      // Step 2: Initialize payment sheet
      await _initializePaymentSheet(_currentPaymentData!);

      // Step 3: Present payment sheet and handle result
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

      onPaymentFailure?.call(result);
      return result;
    } catch (e) {
      _log('Unexpected error during payment process: $e');

      final result = PaymentResult.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );

      onPaymentFailure?.call(result);
      return result;
    }
  }

  /// Convenience method for simple payments
  Future<PaymentResult> makePayment({
    required BuildContext context,
    required double amount,
    String currency = 'USD',
    String? description,
  }) async {
    return processPayment(
      context: context,
      amount: amount,
      currency: currency,
      description: description,
    );
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
