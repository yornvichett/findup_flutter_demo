import 'package:findup_mvvm/Core/constants/app_color.dart';
import 'package:findup_mvvm/Core/constants/text_helper.dart';
import 'package:findup_mvvm/Core/navigation/navigation.dart';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:findup_mvvm/Pages/_Chat/Admin/admin_chat_page.dart';
import 'package:findup_mvvm/Pages/_Profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListAllUserChatPage extends StatefulWidget {
  final UserModel userAdmin;
  ListAllUserChatPage({super.key,required this.userAdmin});

  @override
  State<ListAllUserChatPage> createState() => _ListAllUserChatPageState();
}


class _ListAllUserChatPageState extends State<ListAllUserChatPage> {
  TextHelper textHelper = TextHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().chatGetUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text("Messages", style: textHelper.textAppBarStyle()),
        // leading: GestureDetector(
        //   onTap: () {
        //     Navigation.goPage(context: context, page: ProfileOwnerPage());
        //   },
        //   child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Icon(Icons.arrow_back_ios_new),
        //   ),
        // ),
        backgroundColor: AppColor.appBarColor,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: userViewModel.isLoading
          ? SizedBox()
          : ListView.builder(
              itemCount: userViewModel.listChatUser.length,
              itemBuilder: (context, index) {
                UserModel clientUser = userViewModel.listChatUser[index];
                return ChatUserTile(
                  name: clientUser.name,
                  lastMessage: clientUser.message,
                  avatarUrl: clientUser.userProfile,
                  isRead: clientUser.isRead==1?true:false,
                  onTap: () {
                    Navigation.goReplacePage(context: context, page: AdminChatPage(clientUser: clientUser,userAdmin: widget.userAdmin,));
                  },
                );
              },
            ),
    );
  }
}

class ChatUserTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final bool isRead;
  final VoidCallback onTap;

  const ChatUserTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            CircleAvatar(radius: 26, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage==''?'Sent':lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: isRead? Colors.grey.shade600:lastMessage==''?Colors.grey.shade600:Colors.black),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
