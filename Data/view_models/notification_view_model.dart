import 'package:findup_mvvm/Data/view/notification_view.dart';
import 'package:flutter/material.dart';

class NotificationViewModel extends ChangeNotifier {
  bool isLoading = false;
  NotificationView notificationViewModel = NotificationView();

  Future<void> pushChatNotification({
    required Map<String, dynamic> jsonBody,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      notificationViewModel.pushNotificationChat(jsonBody: jsonBody);
    } catch (e) {
 
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
