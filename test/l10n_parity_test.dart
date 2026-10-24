import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every string must exist in both languages with the same placeholders.
/// gen-l10n silently falls back to English for a key missing from app_fr.arb,
/// so without this check a French user just sees English with no error.
void main() {
  Map<String, dynamic> load(String name) =>
      jsonDecode(File('lib/l10n/$name').readAsStringSync())
          as Map<String, dynamic>;

  final en = load('app_en.arb');
  final fr = load('app_fr.arb');

  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((key) => !key.startsWith('@')).toSet();

  // Placeholder names used in a message, e.g. {count} or {name}. ICU plural
  // branches ("=1{...}", "other{...}") are not placeholders.
  Set<String> placeholders(String message) => RegExp(r'\{(\w+)[,}]')
      .allMatches(message)
      .map((match) => match.group(1)!)
      .toSet();

  test('app_en.arb and app_fr.arb define the same keys', () {
    final enKeys = messageKeys(en);
    final frKeys = messageKeys(fr);

    expect(enKeys.difference(frKeys), isEmpty,
        reason: 'Missing from app_fr.arb');
    expect(frKeys.difference(enKeys), isEmpty,
        reason: 'Missing from app_en.arb');
  });

  test('translations use the same placeholders', () {
    for (final key in messageKeys(en).intersection(messageKeys(fr))) {
      expect(
        placeholders(fr[key] as String),
        placeholders(en[key] as String),
        reason: 'Placeholders differ for "$key"',
      );
    }
  });

  test('no translation is empty', () {
    for (final arb in [en, fr]) {
      for (final key in messageKeys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty,
            reason: '"$key" is empty in ${arb['@@locale']}');
      }
    }
  });
}
