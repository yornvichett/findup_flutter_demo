import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/refresh_version_model.dart';

class RefreshVersionView {
  ApiClient apiClient = ApiClient();

  Future<List<RefreshVersionModel>> getRefreshVersion() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listJson = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listJson
            .map((e) => RefreshVersionModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
