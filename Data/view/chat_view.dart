import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/chat_model.dart';

class ChatView {
  ApiClient _apiClient = ApiClient();

  //admin_remove_chat
  Future<List<ChatModel>> adminRemoveChat({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _apiClient.post('fake_endpoint', body);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return result.map((e) => ChatModel.fromJson(jsonResponse: e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<ChatModel>> userRemoveChat({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _apiClient.post('fake_endpoint', body);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return result.map((e) => ChatModel.fromJson(jsonResponse: e)).toList();
      } else {
        return [];
      }
    } catch (e) {
   
      return [];
    }
  }

  Future<List<ChatModel>> userSListMessage({
    required Map<String, dynamic> body,
  }) async {
    try {
      var response = await _apiClient.post('fake_endpoint', body);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return result.map((e) => ChatModel.fromJson(jsonResponse: e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> adminSentMessage({required Map<String, dynamic> body}) async {
    try {
      var response = await _apiClient.post('fake_endpoint', body);
      if (response.statusCode == 200) {}
    } catch (e) {}
  }

  Future<void> userSentMessage({required Map<String, dynamic> body}) async {
    try {
      var response = await _apiClient.post('fake_endpoint', body);
      if (response.statusCode == 200) {}
    } catch (e) {}
  }
}
