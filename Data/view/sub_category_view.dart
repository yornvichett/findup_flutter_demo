import 'package:findup_mvvm/Core/network/api_client.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';

class SubCategoryView {
  ApiClient apiClient = ApiClient();

  Future<List<SubCategoryModel>> filterSubCategory({
    required int groupCategoryID,
  }) async {
    try {
      var response = await apiClient.post('fake_endpoint', {
       
      });
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listJson = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listJson
            .map((e) => SubCategoryModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<SubCategoryModel>> getAllSubCategory() async {
    try {
      var response = await apiClient.post('fake_endpoint', {
   
      });
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> listJson = List<Map<String, dynamic>>.from(
          response.data['data'],
        );
        return listJson
            .map((e) => SubCategoryModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
