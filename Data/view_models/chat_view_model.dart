import 'package:findup_mvvm/Data/models/chat_model.dart';
import 'package:findup_mvvm/Data/view/chat_view.dart';
import 'package:flutter/cupertino.dart';

class ChatViewModel extends ChangeNotifier {
  bool isLoading = false;
  ChatView chatView = ChatView();
  List<ChatModel> listUserMessage = [];
    Future<void> adminRemoveChat({required Map<String, dynamic> body}) async {
    isLoading = true;
    notifyListeners();
    try {
      await chatView.adminRemoveChat(body: body);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> userRemoveChat({required Map<String, dynamic> body}) async {
    isLoading = true;
    notifyListeners();
    try {
      await chatView.userRemoveChat(body: body);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> userListMessage({required Map<String, dynamic> body}) async {
    isLoading = true;
    notifyListeners();
    try {
      listUserMessage = await chatView.userSListMessage(body: body);
    } catch (e) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adminSentMessage({required Map<String, dynamic> body}) async {
    isLoading = true;
    notifyListeners();
    try {
      await chatView.adminSentMessage(body: body);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> userSentMessage({required Map<String, dynamic> body}) async {
    isLoading = true;
    notifyListeners();
    try {
      await chatView.userSentMessage(body: body);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
