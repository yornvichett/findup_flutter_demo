class ChatModel {
   int id;
   int userID;
   int adminID;
   int chatThreadID;
   String message;
   String senderRolw;
   String createdAt;
   String imageURL;
   int isRead;

  ChatModel({
    required this.id,
    required this.userID,
    required this.adminID,
    required this.chatThreadID,
    required this.message,
    required this.senderRolw,
    required this.createdAt,
    required this.imageURL,
    required this.isRead,
  });

  factory ChatModel.fromJson({required Map<String, dynamic> jsonResponse}) {
    return ChatModel(
      id: jsonResponse['xx']??0,
      userID: jsonResponse['xxxx']??0,
      chatThreadID: jsonResponse['xxxx']??0,
      adminID: jsonResponse['xx']??0,
      message: jsonResponse['xxxx']??'',
      senderRolw: jsonResponse['xxxxx']??'',
      createdAt: jsonResponse['xxxxxxx']??'',
      imageURL: jsonResponse['xxxxxx']??'',
      isRead: jsonResponse['x']??0,
    );
  }
}
