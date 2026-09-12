/// Model for a single support message
class SupportMessageModel {
  final String id;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  SupportMessageModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}') ??
          DateTime.now(),
    );
  }
}

/// Response model for GET /supports/my-messages
class SupportListResponse {
  final bool success;
  final String message;
  final List<SupportMessageModel> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  SupportListResponse({
    required this.success,
    required this.message,
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  factory SupportListResponse.fromJson(Map<String, dynamic> json) {
    // The API may return `data` either as a plain list of messages with the
    // pagination under `meta`, or as a map holding `results` + pagination.
    final data = json['data'];
    final meta = json['meta'] is Map<String, dynamic>
        ? json['meta'] as Map<String, dynamic>
        : (data is Map<String, dynamic> ? data : const <String, dynamic>{});

    final List<dynamic> resultsList = data is List
        ? data
        : (data is Map<String, dynamic> && data['results'] is List
            ? data['results'] as List<dynamic>
            : const <dynamic>[]);

    return SupportListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      results: resultsList
          .whereType<Map<String, dynamic>>()
          .map(SupportMessageModel.fromJson)
          .toList(),
      page: _toInt(meta['page'], 1),
      limit: _toInt(meta['limit'], 10),
      totalPages: _toInt(meta['totalPages'], 1),
      totalResults: _toInt(meta['totalResults'], 0),
    );
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
