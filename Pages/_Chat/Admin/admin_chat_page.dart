import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Core/utils/cache_profile_image.dart';
import 'package:findup_mvvm/Data/models/chat_model.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view_models/chat_view_model.dart';
import 'package:findup_mvvm/Data/view_models/notification_view_model.dart';
import 'package:findup_mvvm/Pages/_Chat/Admin/list_all_user_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminChatPage extends StatefulWidget {
  final UserModel clientUser;
  final UserModel userAdmin;
  const AdminChatPage({
    super.key,
    required this.clientUser,
    required this.userAdmin,
  });

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<List<ChatModel>> tempChatModel = ValueNotifier([]);
  TextHelper textHelper = TextHelper();

  // ============================
  // FORMAT TIME LIKE USER CHAT
  // ============================
  String formatChatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";

    try {
      DateTime date = DateTime.parse(dateString);

      List<String> weekdays = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ];

      String weekday = weekdays[date.weekday - 1];

      return "$weekday • ${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    } catch (e) {
      return "";
    }
  }

  void deleteMessage({
    required ChatModel chat,
    required ChatViewModel chatViewModel,
  }) async {
    tempChatModel.value.remove(chat);
    Map<String, dynamic> body = {
      'chat_id': chat.id,
      'chat_thread_id': 0,
    };

    await chatViewModel.adminRemoveChat(body: body);


    setState(() {});
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
      tempChatModel.value.clear();
      context.read<ChatViewModel>().userListMessage(
        body: {'user_id': widget.clientUser.id},
      );
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if (bottomInset > 0) scrollToBottom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================================
  // SEND MESSAGE (FIXED CREATED_AT)
  // ================================
  void sendMessage({
    required ChatViewModel chatViewModel,
    required NotificationViewModel notificationViewModel,
  }) async {
    if (_messageController.text.trim().isEmpty) return;

    String text = _messageController.text.trim();
    Map<String, dynamic> body = {
      'admin_id': widget.userAdmin.id,
      'user_id': widget.clientUser.id,
      'message': text,
      'sender_role': 'admin',
      'image_url': 'default.jpg',
    };

    bool success = await chatViewModel.adminSentMessage(body: body);

    if (success) {
      Map<String, dynamic> jsonBody = {
        'token': widget.clientUser.fcmToken,
        'title': widget.userAdmin.name,
        'body': text,
      };

      await notificationViewModel.pushChatNotification(jsonBody: jsonBody);

      // ⭐ ADD TIME HERE SO UI CAN SHOW IT
      body["created_at"] = DateTime.now().toString();

      ChatModel chatModel = ChatModel.fromJson(jsonResponse: body);
      tempChatModel.value.add(chatModel);
      scrollToBottom();
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ChatViewModel chatViewModel = context.watch<ChatViewModel>();
    NotificationViewModel notificationViewModel = context
        .watch<NotificationViewModel>();
    tempChatModel.value = chatViewModel.listUserMessage;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        leading: GestureDetector(
          onTap: () {
            Navigation.goReplacePage(
              context: context,
              page: ListAllUserChatPage(userAdmin: widget.userAdmin),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        title: Row(
          children: [
            CacheProfileImage(userProfileImage: widget.clientUser.userProfile),
            const SizedBox(width: 10),
            Text(
              widget.clientUser.name,
              style: textHelper.textAppBarStyle(fontSize: 20),
            ),
          ],
        ),
      ),

      body: chatViewModel.isLoading && tempChatModel.value.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: tempChatModel.value.length,
                      itemBuilder: (context, index) {
                        ChatModel chatModel = tempChatModel.value[index];
                        bool isAdmin = chatModel.senderRolw == "admin";

                        return GestureDetector(
                          onTap: () {

                            if (isAdmin) {
                              return showMessageOptions(
                                chat: chatModel,
                                chatViewModel: chatViewModel,
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            child: Align(
                              alignment: isAdmin
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                decoration: BoxDecoration(
                                  color: !isAdmin
                                      ? Colors.grey.shade300
                                      : Colors.blue.shade600,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(
                                      !isAdmin ? 0 : 16,
                                    ),
                                    bottomRight: Radius.circular(
                                      !isAdmin ? 16 : 0,
                                    ),
                                  ),
                                ),

                                // ============================
                                // MESSAGE + TIME
                                // ============================
                                child: Column(
                                  crossAxisAlignment: isAdmin
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatModel.message,
                                      style: TextStyle(
                                        color: !isAdmin
                                            ? Colors.black87
                                            : Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatChatTime(chatModel.createdAt),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isAdmin
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ============================
                  // INPUT SECTION
                  // ============================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onTap: scrollToBottom,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        chatViewModel.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.blue.shade600,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => sendMessage(
                                    chatViewModel: chatViewModel,
                                    notificationViewModel:
                                        notificationViewModel,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void showMessageOptions({
    required ChatModel chat,
    required ChatViewModel chatViewModel,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ======= HEADER =======
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                // ======= DELETE BUTTON =======
                ListTile(
                  minLeadingWidth: 0,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    "Delete Message",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMessage(chat: chat, chatViewModel: chatViewModel);
                  },
                ),


                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
