import 'dart:convert';
import 'dart:io';
import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/services/local_storage.dart';
import 'package:findup_mvvm/Data/models/chat_model.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view_models/chat_view_model.dart';
import 'package:findup_mvvm/Data/view_models/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserChatPage extends StatefulWidget {
  final UserModel userModel;
  final UserModel userAdmin;

  const UserChatPage({
    super.key,
    required this.userModel,
    required this.userAdmin,
  });

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ValueNotifier<List<ChatModel>> tempChatModel = ValueNotifier([]);
  TextHelper textHelper = TextHelper();

  String? selectedImagePath;

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

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
      return "${weekdays[date.weekday - 1]} • "
          "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    } catch (e) {
      return "";
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => selectedImagePath = image.path);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ChatViewModel vm = context.read<ChatViewModel>();
      await vm.userListMessage(body: {'user_id': widget.userModel.id});
      tempChatModel.value = vm.listUserMessage;
      scrollToBottom();
    });
  }

  @override
  void didChangeMetrics() {
    if (WidgetsBinding.instance.window.viewInsets.bottom > 0) scrollToBottom();
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================
  // 🔥 SHOW OPTIONS (EDIT/DELETE)
  // ============================
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

  // ============================
  // 🔥 DELETE MESSAGE FEATURE
  // ============================
  void deleteMessage({
    required ChatModel chat,
    required ChatViewModel chatViewModel,
  }) async {
    tempChatModel.value.remove(chat);
    Map<String, dynamic> body = {
      'chat_id': chat.id,
      'chat_thread_id': chat.chatThreadID,
    };

    await chatViewModel.userRemoveChat(body: body);


    setState(() {});
  }

  // ============================
  // SEND TEXT ONLY
  // ============================
  Future<void> sendMessage({
    required ChatViewModel chatViewModel,
    required NotificationViewModel notificationViewModel,
  }) async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    Map<String, dynamic> body = {
      'user_id': widget.userModel.id,
      'admin_id': widget.userAdmin.id,
      'message': text,
      'sender_role': 'user',
      'image_url': 'default.jpg',
    };

    bool success = await chatViewModel.userSentMessage(body: body);

    if (success) {
      Map<String, dynamic> jsonBody = {
        'token': widget.userAdmin.fcmToken,
        'title': widget.userModel.name,
        'body': text,
      };
      await notificationViewModel.pushChatNotification(jsonBody: jsonBody);
      ChatModel newMessage = ChatModel.fromJson(
        jsonResponse: {
          "message": text,
          "sender_role": "user",
          "image_url": "default.jpg",
          "created_at": DateTime.now().toString(),
        },
      );

      tempChatModel.value = [...tempChatModel.value, newMessage];
      scrollToBottom();
    }

    _messageController.clear();
  }

  // ============================
  // BUILD PAGE
  // ============================
  @override
  Widget build(BuildContext context) {
    ChatViewModel chatViewModel = context.watch<ChatViewModel>();
    NotificationViewModel notificationViewModel = context
        .watch<NotificationViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade200,

      appBar: AppBar(
        backgroundColor: AppColor.appBarColor,
        elevation: 1,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/findUp.png'),
            ),
            const SizedBox(width: 10),
            Text("Support", style: textHelper.textAppBarStyle()),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ValueListenableBuilder(
        valueListenable: tempChatModel,
        builder: (context, list, _) {
          return Column(
            children: [
              list.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Image.asset(
                          'assets/images/findup_chat.png',
                          height: 100,
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          ChatModel chat = list[index];
                          bool isAdmin = chat.senderRolw == "admin";

                          return GestureDetector(
                            onLongPress: () {
                              if (!isAdmin) {
                                return showMessageOptions(
                                  chat: chat,
                                  chatViewModel: chatViewModel,
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              child: Align(
                                alignment: isAdmin
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  constraints: const BoxConstraints(
                                    maxWidth: 280,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAdmin
                                        ? Colors.grey.shade300
                                        : Colors.blue.shade600,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(
                                        isAdmin ? 0 : 16,
                                      ),
                                      bottomRight: Radius.circular(
                                        isAdmin ? 16 : 0,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isAdmin
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        chat.message,
                                        style: TextStyle(
                                          color: isAdmin
                                              ? Colors.black87
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatChatTime(chat.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isAdmin
                                              ? Colors.black54
                                              : Colors.white70,
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

              // INPUT BAR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onTap: scrollToBottom,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    chatViewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.blue)
                        : CircleAvatar(
                            backgroundColor: Colors.blue.shade600,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: () => sendMessage(
                                chatViewModel: chatViewModel,
                                notificationViewModel: notificationViewModel,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
