import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/group_category_model.dart';

class GroupCategoryView {
  ApiClient apiClient = ApiClient();

  Future<List<GroupCategoryModel>> getAllGroupCategory() async {
    try {
      var response = await apiClient.post('fake_endpoint', {});
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = List<Map<String,dynamic>>.from( response.data['data']);
        return result
            .map((e) => GroupCategoryModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }
}
