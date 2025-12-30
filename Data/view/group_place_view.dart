import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';

class GroupPlaceView {
  ApiClient apiClient = ApiClient();

  Future<List<GroupPlaceModel>> getAllGroupPlace() async {

    try {
      var response = await apiClient.post("fake_endpoint", {});
      if (response.statusCode == 200) {
        var jsonResponse =
            List<Map<String, dynamic>>.from(response.data['data']);

      
        return jsonResponse
            .map((e) => GroupPlaceModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
