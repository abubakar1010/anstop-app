import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;

  /// Free-form hint from the server (e.g. "payment", "wallet"); picks the icon.
  final String iconKey;
  final DateTime dateTime;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.dateTime,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      iconKey: (json['icon'] ?? '').toString().toLowerCase(),
      dateTime:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
    );
  }

  IconData get icon {
    if (iconKey.contains('wallet')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (iconKey.contains('card')) return Icons.credit_card_outlined;
    if (iconKey.contains('pay')) return Icons.credit_card;
    if (iconKey.contains('discount') || iconKey.contains('offer')) {
      return Icons.local_offer;
    }
    if (iconKey.contains('ride') || iconKey.contains('car')) {
      return Icons.directions_car_outlined;
    }
    return Icons.notifications_none;
  }
}

class NotificationGroup {
  final String dateLabel;
  final List<NotificationModel> notifications;

  NotificationGroup({
    required this.dateLabel,
    required this.notifications,
  });
}
