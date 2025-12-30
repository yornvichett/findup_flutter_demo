import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/app_config_model.dart';

class AppConfigView {
  ApiClient apiClient = ApiClient();

  Future<List<AppConfigModel>> getAppConfig() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listResponse =
            List<Map<String, dynamic>>.from(response.data['data']);
        return listResponse
            .map((e) => AppConfigModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
