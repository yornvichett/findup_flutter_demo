import 'package:findup_mvvm/Core/network/api_client.dart';

class NotificationView {
  ApiClient _apiClient = ApiClient();

  Future<void> pushNotificationChat({
    required Map<String, dynamic> jsonBody,
  }) async {
    try {
      await _apiClient.post('fake_endpoint', jsonBody);
    } catch (e) {

    }
  }
}
