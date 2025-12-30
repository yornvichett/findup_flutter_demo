import 'package:findup_mvvm/Core/network/api_client.dart';

class NotificationService {
  ApiClient apiClient = ApiClient();

  Future<void> sentNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    try {
      Map<String, dynamic> jsonBody = {
        'token': fcmToken,
        'title': title,
        'body': body,
      };
      await apiClient.post('send_fcm', jsonBody);
    } catch (e) {
    }
  }
}
