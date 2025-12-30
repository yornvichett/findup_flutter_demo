import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/slide_model.dart';

class SlideView {
  ApiClient apiClient = ApiClient();

  Future<List<SlideModel>> getTopListADS() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listJson = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listJson.map((e) => SlideModel.fromJson(jsonBody: e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  Future<List<SlideModel>> getBottomListADS() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listJson = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listJson.map((e) => SlideModel.fromJson(jsonBody: e)).toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
