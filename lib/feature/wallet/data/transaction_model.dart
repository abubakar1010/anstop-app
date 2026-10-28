import 'package:ride_sharing/l10n/l10n_helper.dart';

class TransactionResponseModel {
  final bool success;
  final String message;
  final TransactionPagination data;

  TransactionResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TransactionPagination.fromJson(json['data'], meta: json['meta']),
    );
  }
}

class TransactionPagination {
  final List<TransactionModel> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  TransactionPagination({
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  /// The list endpoint sends the rows as `data` and the page info as a
  /// separate `meta` object.
  factory TransactionPagination.fromJson(dynamic data, {dynamic meta}) {
    if (data is List) {
      final info = meta is Map ? meta : const {};
      return TransactionPagination(
        results: data.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList(),
        page: (info['page'] as num?)?.toInt() ?? 1,
        limit: (info['limit'] as num?)?.toInt() ?? data.length,
        totalPages: (info['totalPages'] as num?)?.toInt() ?? 1,
        totalResults: (info['totalResults'] as num?)?.toInt() ?? data.length,
      );
    }
    final json = data as Map<String, dynamic>? ?? {};
    return TransactionPagination(
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      totalResults: json['totalResults'] ?? 0,
    );
  }
}
/// How one transaction reads for the person looking at it.
class TransactionView {
  final String title;
  final double amount;
  final bool isPositive;

  const TransactionView(this.title, this.amount, this.isPositive);
}

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String status;
  final String riderId;
  final String driverId;
  /// The driver's share of a ride, after commission.
  final double? driverEarning;
  /// "WALLET" or "STRIPE" (card).
  final String method;
  final String? accountNumber;
  final String? accountHolderName;
  final String? accountType;
  final String? bankName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.riderId = '',
    this.driverId = '',
    this.driverEarning,
    this.method = '',
    this.accountNumber,
    this.accountHolderName,
    this.accountType,
    this.bankName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// One ride appears in both the rider's and the driver's list: a cost for
  /// one, earnings for the other. [myUserId] picks the side.
  TransactionView viewFor(String myUserId) {
    final tr = AppLocalization.tr;
    final isDriverSide = driverId.isNotEmpty && driverId == myUserId;
    switch (type) {
      case 'DEPOSIT':
        return TransactionView(tr.walletDepositLabel, amount, true);
      case 'WITHDRAWAL':
        return TransactionView(tr.withdrawalToBankLabel, amount, false);
      case 'REFUND':
        return TransactionView(tr.refundLabel, amount, true);
      case 'RIDE_TIP':
        return isDriverSide
            ? TransactionView(tr.tipReceivedLabel, amount, true)
            : TransactionView(tr.tipPaidLabel, amount, false);
      case 'RIDE':
        if (isDriverSide) {
          return TransactionView(tr.rideEarningLabel, driverEarning ?? amount, true);
        }
        return TransactionView(
          method == 'WALLET' ? tr.ridePaidFromWalletLabel : tr.ridePaidByCardLabel,
          amount,
          false,
        );
      default:
        return TransactionView(type, amount, false);
    }
  }

  /// A reference may come back as an id or as a populated user.
  static String _idOf(dynamic value) =>
      value is Map ? '${value['_id'] ?? ''}' : '${value ?? ''}';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? '',
      userId: _idOf(json['userId']),
      amount: (json['amount'] as num? ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      riderId: _idOf(json['riderId']),
      driverId: _idOf(json['driverId']),
      driverEarning: (json['driverEarning'] as num?)?.toDouble(),
      method: json['method'] ?? '',
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
      accountType: json['accountType'],
      bankName: json['bankName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
