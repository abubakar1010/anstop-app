import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/feature/messages/message_utils/chat_bubble.dart';
import 'package:ride_sharing/feature/messages/view/block_dialog.dart';
import 'package:ride_sharing/feature/messages/view/media_grid_screen.dart';
import 'package:ride_sharing/feature/messages/view/report_screen.dart';
import '../../../app/utils/app_colors.dart';
import '../controller/chat_controller.dart';


class ChatScreen extends GetView<ChatController> {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: MessagingColors.primaryText,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: MessagingColors.primaryGreen,
              child: Text(
                controller.userName.isNotEmpty
                    ? controller.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName,
                  style: const TextStyle(
                    color: MessagingColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(() => Text(
                  controller.isConnected.value
                      ? 'Online'
                      : controller.userStatus,
                  style: TextStyle(
                    color: controller.isConnected.value
                        ? MessagingColors.primaryGreen
                        : MessagingColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                )),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: MessagingColors.primaryText,
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refreshMessages,
                        child: Text(AppLocalization.tr.retryButton),
                      ),
                    ],
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalization.tr.noMessagesYetMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MessagingColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshMessages,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  // Add 1 for the loading/end indicator at the top
                  itemCount: controller.messages.length + 1,
                  itemBuilder: (context, index) {
                    // First item is the loading indicator or "no more messages"
                    if (index == 0) {
                      return _buildPaginationIndicator();
                    }

                    // Adjust index for actual messages
                    final messageIndex = index - 1;
                    final message = controller.messages[messageIndex];
                    // Check if we should show sender info
                    // Show sender info if it's a received message and different sender from previous
                    bool showSenderInfo = !message.isSent;
                    if (!message.isSent && messageIndex > 0) {
                      final prevMessage = controller.messages[messageIndex - 1];
                      // Hide sender info if same sender as previous message
                      if (prevMessage.senderId == message.senderId) {
                        showSenderInfo = false;
                      }
                    }
                    return ChatBubble(
                      message: message.text,
                      isSent: message.isSent,
                      time: message.formattedTime,
                      senderName: message.senderName,
                      senderProfilePicture: message.senderProfilePicture,
                      showSenderInfo: showSenderInfo,
                    );
                  },
                ),
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuOption(
              AppLocalization.tr.viewMediaOption,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MediaGridScreen(),
                  ),
                );
              },
            ),
            _buildMenuOption(
              AppLocalization.tr.reportOption,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportScreen(),
                  ),
                );
              },
            ),
            _buildMenuOption(
              AppLocalization.tr.blockOption,
              () {
                Navigator.pop(context);
                _showBlockDialog(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => BlockDialog(
        userName: controller.userName,
        onBlock: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildMenuOption(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: MessagingColors.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: MessagingColors.backgroundColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: controller.messageTEController,
                decoration: InputDecoration(
                  hintText: AppLocalization.tr.typeMessageHint,
                  hintStyle: const TextStyle(
                    color: MessagingColors.secondaryText,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.attach_file,
              color: MessagingColors.secondaryText,
            ),
            onPressed: controller.sendMedia,
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: MessagingColors.primaryGreen,
            ),
            onPressed: controller.sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationIndicator() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: MessagingColors.primaryGreen,
            ),
          ),
        );
      }

      if (!controller.hasMoreMessages.value && controller.messages.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: MessagingColors.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              AppLocalization.tr.beginningOfConversationLabel,
              style: TextStyle(
                color: MessagingColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }

      // Empty container when there are more messages to load but not currently loading
      return const SizedBox(height: 8);
    });
  }
}
