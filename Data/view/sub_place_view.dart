import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_place_model.dart';

class SubPlaceView {
  ApiClient apiClient = ApiClient();

  Future<List<SubPlaceModel>> getSubPlace({required int groupPlaceID}) async {
    try {
      Map<String, dynamic> dataSend = {};
      var respons = await apiClient.post('fake_endpoint', dataSend);
      if (respons.statusCode == 200) {
        List<Map<String, dynamic>> listResponse =
            List<Map<String, dynamic>>.from(respons.data['data']);
        return listResponse
            .map((e) => SubPlaceModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
