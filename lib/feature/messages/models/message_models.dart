import 'package:intl/intl.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class Message {
  final String name;
  final String message;
  final String time;
  final String? avatarUrl;
  final bool hasUnread;

  Message({
    required this.name,
    required this.message,
    required this.time,
    this.avatarUrl,
    this.hasUnread = false,
  });
}

class MessageSender {
  final String id;
  final String name;
  final String? profilePicture;

  MessageSender({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  factory MessageSender.fromJson(dynamic json) {
    if (json is String) {
      // Handle case where sender is just an ID string
      return MessageSender(id: json, name: AppLocalization.tr.unknownUserName);
    }
    if (json is Map<String, dynamic>) {
      return MessageSender(
        id: json['_id'] ?? '',
        name: json['name'] ?? AppLocalization.tr.unknownUserName,
        profilePicture: json['profilePicture'],
      );
    }
    return MessageSender(id: '', name: AppLocalization.tr.unknownUserName);
  }
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String conversationId;
  final String text;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSent;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.conversationId,
    required this.text,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    required this.isSent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final sender = MessageSender.fromJson(json['sender']);
    return ChatMessage(
      id: json['_id'] ?? '',
      sender: sender,
      conversationId: json['conversation'] ?? '',
      text: json['text'] ?? '',
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'].where((a) => a != null && a.toString().isNotEmpty))
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isSent: sender.id == currentUserId,
    );
  }

  // Constructor for locally created messages (optimistic UI)
  factory ChatMessage.local({
    required String currentUserId,
    required String currentUserName,
    String? currentUserProfilePicture,
    required String conversationId,
    required String text,
    List<String>? attachments,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender(
        id: currentUserId,
        name: currentUserName,
        profilePicture: currentUserProfilePicture,
      ),
      conversationId: conversationId,
      text: text,
      attachments: attachments ?? [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSent: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': {
        '_id': sender.id,
        'name': sender.name,
        'profilePicture': sender.profilePicture,
      },
      'conversation': conversationId,
      'text': text,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Follows the app language: "2:05 PM" in English, "14:05" in French.
  String get formattedTime => DateFormat.jm().format(createdAt);

  // Convenience getters
  String get senderName => sender.name;
  String? get senderProfilePicture => sender.profilePicture;
  String get senderId => sender.id;
}

class MessagesResponse {
  final int statusCode;
  final bool success;
  final String message;
  final MessagesData data;

  MessagesResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json, String currentUserId) {
    return MessagesResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: MessagesData.fromJson(json['data'] ?? {}, currentUserId),
    );
  }
}

class MessagesData {
  final List<ChatMessage> results;
  final int page;
  final int limit;
  final int totalPages;
  final int totalResults;

  MessagesData({
    required this.results,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.totalResults,
  });

  factory MessagesData.fromJson(Map<String, dynamic> json, String currentUserId) {
    return MessagesData(
      results: json['results'] != null
          ? (json['results'] as List)
              .map((msg) => ChatMessage.fromJson(msg, currentUserId))
              .toList()
          : [],
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      totalResults: json['totalResults'] ?? 0,
    );
  }
}