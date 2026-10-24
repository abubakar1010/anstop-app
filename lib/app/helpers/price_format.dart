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
