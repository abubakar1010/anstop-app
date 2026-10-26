import 'package:flutter/material.dart';

/// A card the rider saved with Stripe. Only display details ever reach the app.
class SavedCard {
  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  const SavedCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: (json['id'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString().toLowerCase(),
      last4: (json['last4'] ?? '').toString(),
      expMonth: (json['expMonth'] as num?)?.toInt() ?? 0,
      expYear: (json['expYear'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] == true,
    );
  }

  static List<SavedCard> listFromJson(dynamic data) => [
        if (data is List)
          for (final item in data)
            if (item is Map) SavedCard.fromJson(Map<String, dynamic>.from(item)),
      ];

  String get maskedNumber => '•••• $last4';

  /// MM/YY, as printed on the card.
  String get expiry =>
      '${expMonth.toString().padLeft(2, '0')}/${(expYear % 100).toString().padLeft(2, '0')}';

  /// Cards are valid through the last day of their expiry month.
  bool isExpired([DateTime? now]) {
    final today = now ?? DateTime.now();
    return expYear < today.year || (expYear == today.year && expMonth < today.month);
  }

  String get brandName {
    switch (brand) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'American Express';
      case 'cartes_bancaires':
        return 'Carte Bancaire';
      case 'discover':
        return 'Discover';
      case 'diners':
        return 'Diners Club';
      case 'jcb':
        return 'JCB';
      case 'unionpay':
        return 'UnionPay';
      default:
        return brand.isEmpty ? 'Card' : brand[0].toUpperCase() + brand.substring(1);
    }
  }

  /// Brand colour for the card badge.
  Color get brandColor {
    switch (brand) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF2E77BC);
      case 'cartes_bancaires':
        return const Color(0xFF00A0DF);
      default:
        return const Color(0xFF0D4D3D);
    }
  }
}
