import 'package:intl/intl.dart';
import 'package:ride_sharing/services/locale_service.dart';

/// Formats [amount] (a number, or a numeric string from the API) as euros in
/// the active language: "€24.50" in English, "24,50 €" in French. Returns an
/// empty string when [amount] is not a number.
String formatPrice(Object? amount, {int decimals = 2}) {
  final value = amount is num ? amount : num.tryParse('${amount ?? ''}');
  if (value == null) return '';
  return NumberFormat.currency(
    locale: LocaleService.languageCode,
    symbol: '€',
    decimalDigits: decimals,
  ).format(value);
}

/// Reads an amount typed by the user. Accepts a comma or a dot as the decimal
/// separator ("12,50" and "12.50"), so French users can type amounts the way
/// they write them. Returns null when it is not a number.
double? parseAmount(String text) {
  final normalized = text.replaceAll(RegExp(r'[\s€]'), '').replaceAll(',', '.');
  return double.tryParse(normalized);
}

/// "0.00" in English, "0,00" in French: a placeholder for amount fields.
String amountPlaceholder() => NumberFormat('0.00', LocaleService.languageCode).format(0);
