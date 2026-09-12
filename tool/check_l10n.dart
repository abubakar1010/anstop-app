// Verifies the ARB files stay in sync. Run: dart tool/check_l10n.dart
//
// Catches the two ways translations silently rot: a key added to one locale
// but not the other, and a key whose French was never actually translated.
import 'dart:convert';
import 'dart:io';

const _sameInBothIsFine = <String>{
  // Proper nouns, symbols and words that are genuinely identical in French.
  'onboardingAppName', 'emailLabel', 'noteLabel', 'logoLabel', 'okButton',
  'accountInactiveButton', 'destination', 'distanceLabel', 'infoTitle',
  'notificationTitle',
  'notificationMenuItem',
  'supportTitle',
  'supportMenuItem',
  'restaurantCategory', 'messagesTitle', 'transactionsTitle', 'andText',
};

Map<String, String> _load(String path) {
  final raw = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in raw.entries)
      if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
  };
}

void main() {
  final en = _load('lib/l10n/app_en.arb');
  final fr = _load('lib/l10n/app_fr.arb');
  final problems = <String>[];

  for (final k in en.keys.where((k) => !fr.containsKey(k))) {
    problems.add('missing from app_fr.arb: $k');
  }
  for (final k in fr.keys.where((k) => !en.containsKey(k))) {
    problems.add('missing from app_en.arb: $k');
  }
  for (final k in en.keys.where(fr.containsKey)) {
    if (_sameInBothIsFine.contains(k)) continue;
    // Sample/placeholder copy is mock data, not user-facing prose.
    if (k.contains('Example') ||
        k.startsWith('example') ||
        en[k]!.startsWith('Lorem ipsum'))
      continue;
    if (en[k]!.trim().isNotEmpty && en[k]!.trim() == fr[k]!.trim()) {
      problems.add('untranslated (en == fr): $k -> "${en[k]}"');
    }
  }

  if (problems.isEmpty) {
    stdout.writeln('l10n OK - ${en.length} keys, en/fr in sync.');
    return;
  }
  stderr.writeln('l10n check failed (${problems.length}):');
  for (final p in problems) {
    stderr.writeln('  $p');
  }
  exit(1);
}
