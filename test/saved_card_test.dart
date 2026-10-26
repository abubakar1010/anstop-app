import 'package:flutter_test/flutter_test.dart';
import 'package:ride_sharing/feature/payment_methods/data/saved_card.dart';

void main() {
  test('parses the server card summary', () {
    final cards = SavedCard.listFromJson([
      {'id': 'pm_1', 'brand': 'visa', 'last4': '4242', 'expMonth': 4, 'expYear': 2030, 'isDefault': true},
      {'id': 'pm_2', 'brand': 'cartes_bancaires', 'last4': '0005', 'expMonth': 12, 'expYear': 2027},
      'not a card',
    ]);
    expect(cards, hasLength(2));
    expect(cards.first.isDefault, isTrue);
    expect(cards.last.isDefault, isFalse);
    expect(cards.first.brandName, 'Visa');
    expect(cards.last.brandName, 'Carte Bancaire');
  });

  test('shows only the last digits and the printed expiry', () {
    final card = SavedCard.fromJson({'id': 'pm_1', 'brand': 'mastercard', 'last4': '4444', 'expMonth': 3, 'expYear': 2029});
    expect(card.maskedNumber, '•••• 4444');
    expect(card.expiry, '03/29');
  });

  test('a card stays valid through its expiry month', () {
    final card = SavedCard.fromJson({'id': 'pm_1', 'last4': '1', 'expMonth': 10, 'expYear': 2026});
    expect(card.isExpired(DateTime(2026, 10, 31)), isFalse);
    expect(card.isExpired(DateTime(2026, 11, 1)), isTrue);
    expect(card.isExpired(DateTime(2025, 12, 1)), isFalse);
  });
}
