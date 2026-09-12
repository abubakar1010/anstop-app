import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ride_sharing/l10n/l10n_helper.dart';
import 'package:ride_sharing/feature/messages/message_utils/message_list_items.dart';
import 'package:ride_sharing/feature/messages/models/message_models.dart';
import 'package:ride_sharing/feature/messages/view/chat_screen.dart';
import '../../../app/utils/app_colors.dart';
import '../../../widgets/custom_text_field.dart';


class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({Key? key}) : super(key: key);

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Message> messages = [
    Message(
      name: 'David',
      message: 'Hello, How are you ?',
      time: '2:30 PM',
      hasUnread: true,
    ),
    Message(
      name: 'Isabella',
      message: 'Hello, How are you ?',
      time: '1:30 PM',
      hasUnread: true,
    ),
    Message(
      name: 'Thomas',
      message: 'Hello, How are you ?',
      time: '1:30 PM',
      hasUnread: false,
    ),
  ];

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
        title: Text(
          AppLocalization.tr.messagesTitle,
          style: TextStyle(
            color: MessagingColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(25),
              ),
              child: CustomTextField(
              controller: _searchController,
              borderColor: Colors.transparent,  // ⭐ Prevents double border
              borderRadio: 25.r,
              suffixIcon: const Icon(
              Icons.search,
              color: MessagingColors.searchIconColor,
              size: 22,
              ),
              hintText: AppLocalization.tr.searchByNameHint,
              hintextColor: MessagingColors.secondaryText,
              ),
              ),

          // Messages List
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return MessageListItem(
                  message: messages[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                         // userName: messages[index].name,
                        //  userStatus: 'Online',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
