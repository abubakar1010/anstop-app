import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../services/socket_services.dart';
import '../models/message_models.dart';
import '../service/message_service.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class ChatController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController messageTEController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ==================== Services ====================
  final MessageService _messageService = MessageService();
  final Logger _logger = Logger();
  late SocketIoService _socketService;

  // ==================== State ====================
  final RxBool isLoading = false.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isConnected = false.obs;

  // ==================== Pagination State ====================
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalResults = 0.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreMessages = true.obs;
  static const int _pageLimit = 20;

  // ==================== Parameters ====================
  String conversationId = '';
  String currentUserId = '';
  String currentUserName = '';
  String? currentUserProfilePicture;
  String userName = '';
  String userStatus = '';

  // ==================== Lifecycle ====================
  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _initializeSocket();
    _loadCurrentUserInfo();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      // Load more when user scrolls near the top (for older messages)
      if (scrollController.position.pixels <=
          scrollController.position.minScrollExtent + 100) {
        loadMoreMessages();
      }
    });
  }

  @override
  void onClose() {
    messageTEController.dispose();
    scrollController.dispose();
    _socketService.offNewMessage();
    _messageListenerRegistered = false;
    super.onClose();
  }

  // ==================== Initialization ====================
  void _loadArguments() {
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      conversationId = args['conversationId'] ?? '';
      userName = args['userName'] ?? 'User';
      userStatus = args['userStatus'] ?? 'Online';
    }
  }

  Future<void> _loadCurrentUserInfo() async {
    final userInfo = await _messageService.getCurrentUserInfo();
    currentUserId = userInfo['userId'] ?? '';
    currentUserName = userInfo['userName'] ?? 'Me';
    currentUserProfilePicture = userInfo['profilePicture'];
    if (conversationId.isNotEmpty) {
      loadMessages();
    }
  }

  Future<void> _initializeSocket() async {
    try {
      _socketService = Get.find<SocketIoService>();

      // Listen for connection status
      ever(_socketService.isConnected, (connected) {
        isConnected.value = connected;
        // Register message listener when socket connects
        if (connected) {
          _registerMessageListener();
        }
      });

      // Connect to socket (async - will trigger isConnected when done)
      await _socketService.connect();

      // Also register immediately if already connected
      if (_socketService.isConnected.value) {
        _registerMessageListener();
      }
    } catch (e) {
      _logger.e('Error initializing socket: $e');
    }
  }

  bool _messageListenerRegistered = false;

  void _registerMessageListener() {
    if (_messageListenerRegistered) return;
    _messageListenerRegistered = true;

    _logger.i('Registering new-message listener');
    _socketService.onNewMessage((data) {
      _logger.i('New message received: $data');
      _handleNewMessage(data);
    });
  }

  void _handleNewMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check if message is for this conversation
      final msgConversationId = data['conversationId'] ?? '';
      if (msgConversationId == conversationId) {
        // Parse sender - could be string ID, object, or not present
        String senderId = '';
        String senderName = userName; // Default to other user's name
        String? senderProfilePicture;

        if (data['sender'] is Map) {
          senderId = data['sender']['_id'] ?? '';
          senderName = data['sender']['name'] ?? userName;
          senderProfilePicture = data['sender']['profilePicture'];
        } else if (data['sender'] is String) {
          senderId = data['sender'];
          senderName = senderId == currentUserId ? currentUserName : userName;
        }
        // If sender is not present, assume it's from the other user (default values above)

        // Don't add if it's our own message (we already added it optimistically)
        // Only skip if senderId is non-empty and matches currentUserId
        if (senderId.isNotEmpty && currentUserId.isNotEmpty && senderId == currentUserId) {
          return;
        }

        // Check for duplicate message by text and recent timestamp to avoid duplicates
        final messageText = data['text'] ?? '';
        final isDuplicate = messages.any((msg) =>
            msg.text == messageText &&
            DateTime.now().difference(msg.createdAt).inSeconds < 5);
        if (isDuplicate) {
          _logger.i('Duplicate message detected, skipping');
          return;
        }

        final newMessage = ChatMessage(
          id: data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          sender: MessageSender(
            id: senderId,
            name: senderName,
            profilePicture: senderProfilePicture,
          ),
          conversationId: msgConversationId,
          text: messageText,
          attachments: data['attachments'] != null && data['attachments'].toString().isNotEmpty
              ? [data['attachments'].toString()]
              : [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSent: senderId.isNotEmpty && senderId == currentUserId,
        );

        messages.add(newMessage);
        messages.refresh(); // Force UI update
        _scrollToBottom();
      }
    }
  }

  // ==================== Business Logic ====================
  Future<void> loadMessages() async {
    if (conversationId.isEmpty) {
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      // Reset pagination state for fresh load
      currentPage.value = 1;
      hasMoreMessages.value = true;

      final response = await _messageService.getMessages(
        conversationId,
        page: 1,
        limit: _pageLimit,
      );

      if (response.isSuccess) {
        final messagesResponse = MessagesResponse.fromJson(
          response.responseData,
          currentUserId,
        );
        // Sort messages by createdAt ascending (oldest first for proper display)
        final sortedMessages = messagesResponse.data.results.toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        messages.value = sortedMessages;

        // Update pagination state
        currentPage.value = messagesResponse.data.page;
        totalPages.value = messagesResponse.data.totalPages;
        totalResults.value = messagesResponse.data.totalResults;
        hasMoreMessages.value = currentPage.value < totalPages.value;

        _scrollToBottom();
      } else {
        debugPrint('chat_controller: ${response.errorMessage}');
        errorMessage.value = AppLocalization.tr.genericErrorMessage;
        Get.snackbar(
          AppLocalization.tr.errorTitle,
          AppLocalization.tr.genericErrorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('chat_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      _logger.e('Error loading messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more (older) messages when scrolling up
  Future<void> loadMoreMessages() async {
    // Prevent multiple simultaneous loads
    if (isLoadingMore.value || !hasMoreMessages.value || isLoading.value) {
      return;
    }

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;

      _logger.i('Loading more messages - page: $nextPage');

      final response = await _messageService.getMessages(
        conversationId,
        page: nextPage,
        limit: _pageLimit,
      );

      if (response.isSuccess) {
        final messagesResponse = MessagesResponse.fromJson(
          response.responseData,
          currentUserId,
        );

        if (messagesResponse.data.results.isNotEmpty) {
          // Sort new messages by createdAt ascending
          final newMessages = messagesResponse.data.results.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          // Preserve scroll position by calculating the offset
          final previousScrollOffset = scrollController.offset;
          final previousMaxScroll = scrollController.position.maxScrollExtent;

          // Prepend older messages to the beginning
          messages.insertAll(0, newMessages);

          // Update pagination state
          currentPage.value = messagesResponse.data.page;
          hasMoreMessages.value = currentPage.value < messagesResponse.data.totalPages;

          // Restore scroll position after adding new messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              final newMaxScroll = scrollController.position.maxScrollExtent;
              final scrollDelta = newMaxScroll - previousMaxScroll;
              scrollController.jumpTo(previousScrollOffset + scrollDelta);
            }
          });
        } else {
          hasMoreMessages.value = false;
        }
      }
    } catch (e) {
      _logger.e('Error loading more messages: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageTEController.text.trim();
    if (text.isEmpty) return;

    try {
      _logger.i('Sending message: $text');
      _logger.i('Current user ID: $currentUserId');
      _logger.i('Conversation ID: $conversationId');

      // Send message via socket
      final sent = await _socketService.sendMessage(
        conversationId: conversationId,
        text: text,
      );
      if (!sent) throw StateError('Message was not accepted by the server');

      // Optimistically add message to UI
      final newMessage = ChatMessage.local(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserProfilePicture: currentUserProfilePicture,
        conversationId: conversationId,
        text: text,
      );

      _logger.i('Adding message to list. Current count: ${messages.length}');
      messages.add(newMessage);
      messages.refresh(); // Force UI update
      _logger.i('Message added. New count: ${messages.length}');

      messageTEController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('chat_controller: $e');
      errorMessage.value = AppLocalization.tr.genericErrorMessage;
      _logger.e('Error sending message: $e');
      Get.snackbar(
        AppLocalization.tr.errorTitle,
        AppLocalization.tr.messageSendFailedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _scrollToBottom() {
    // Use a slight delay to ensure the list has been rebuilt with the new message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMedia() async {
    // TODO: Implement media sending with attachments
  }

  void blockUser() {
    // TODO: Implement block user functionality
  }

  void reportUser() {
    // TODO: Navigate to report screen
  }

  void onTyping(bool typing) {
    isTyping.value = typing;
    // TODO: Send typing indicator to server
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }
}
