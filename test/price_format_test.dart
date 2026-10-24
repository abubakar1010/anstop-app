import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/app/helpers/price_format.dart';

void main() {
  // French separates groups with a narrow no-break space and puts € last.
  String normalizeSpaces(String text) =>
      text.replaceAll(' ', ' ').replaceAll(' ', ' ');

  tearDown(() => Get.locale = null);

  test('formats euros in English', () {
    Get.locale = const Locale('en');
    expect(formatPrice(1234.5), '€1,234.50');
    expect(formatPrice('24'), '€24.00');
    expect(formatPrice(24, decimals: 0), '€24');
  });

  test('formats euros in French', () {
    Get.locale = const Locale('fr');
    expect(normalizeSpaces(formatPrice(1234.5)), '1 234,50 €');
    expect(normalizeSpaces(formatPrice('24')), '24,00 €');
  });

  test('returns an empty string for non-numbers', () {
    expect(formatPrice(null), '');
    expect(formatPrice('abc'), '');
  });
}
