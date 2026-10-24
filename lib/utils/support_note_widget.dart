import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing/feature/messages/binding/chat_binding.dart';
import 'package:ride_sharing/feature/messages/view/chat_screen.dart';
import 'package:ride_sharing/widgets/auth_links/auth_link.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';

class SupportNoteWidget extends StatelessWidget {
  final String conversationId;
  final String userName;
  final String? userStatus;

  // Constructor
  SupportNoteWidget({
    Key? key,
    required this.conversationId,
    required this.userName,
    this.userStatus,
  }) : super(key: key);

  final TextEditingController supportNoteTEController = TextEditingController();

  void _navigateToChat() {
    Get.to(
      () => const ChatScreen(),
      binding: ChatBinding(),
      arguments: {
        'conversationId': conversationId,
        'userName': userName,
        'userStatus': userStatus ?? AppLocalization.tr.driverLabel,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
        child: Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: supportNoteTEController,
                prefixIcon: GestureDetector(
                  onTap: _navigateToChat,
                  child: Icon(
                    CupertinoIcons.chat_bubble_2,
                    color: AppColors.togglebuttonColor,
                  ),
                ),
                borderRadio: 20,
              ),
            ),
            SizedBox(width: 8.sp),
            GestureDetector(
              onTap: _navigateToChat,
              child: Icon(
                Icons.chat_bubble_outline_outlined,
                color: AppColors.togglebuttonColor,
              ),
            ),
            SizedBox(width: 8.sp),
            Icon(Icons.phone, color: AppColors.togglebuttonColor),
          ],
        ),
      ),
    );
  }
}
