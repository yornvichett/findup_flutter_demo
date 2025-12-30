import 'dart:convert';

import 'package:findup_mvvm/Data/models/group_category_model.dart';
import 'package:findup_mvvm/Data/models/group_place_model.dart';
import 'package:findup_mvvm/Data/models/sub_category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefreshStorage {
  // version
  static String groupCategoryVersionKey = "groupCategoryVersion_key";
  static String groupCategoryKey = "groupCategoryList_key";

  static String subCategoryVersionKey = "subCategoryVersion_key";
  static String subCategoryKey = "subCategoryList_key";

  static String groupPlaceVersionKey = "groupPlaceVersion_key";
  static String groupPlaceKey = "groupPlaceList_key";

  // Group Place =======================================================
  static Future<List<GroupPlaceModel>> getListGroupPlace() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var result = sharedPreferences.getString(groupPlaceKey);
      if (result != null || result == '') {
        List<Map<String, dynamic>> listResult = List<Map<String, dynamic>>.from(
          jsonDecode(result.toString()),
        );
        
        return listResult
            .map((e) => GroupPlaceModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  static void saveListGroupPlace({
    required List<GroupPlaceModel> listData,
  }) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString(groupPlaceKey, jsonEncode(listData));
      var response = sharedPreferences.getString(groupPlaceKey);
    } catch (e) {

    }
  }

  static void saveGroupPlaceVersion({required int version}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Map<String, dynamic> mapJson = {'version': version};
      await sharedPreferences.setString(
        groupPlaceVersionKey,
        jsonEncode(mapJson),
      );
    } catch (e) {

    }
  }

  static Future<Map<String, dynamic>> getGroupPlaceVersion() async {
    Map<String, dynamic> mapData = {};
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var result = sharedPreferences.getString(groupPlaceVersionKey);
      if (result != null || result == '') {
        mapData = jsonDecode(result.toString());
      } else {
        mapData = {"version": 0};
      }

      return mapData;
    } catch (e) {

      return mapData;
    }
  }

  // Sub Category ============================================================
  static Future<Map<String, dynamic>> getSubCategoryVersion() async {
    Map<String, dynamic> mapData = {};
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var result = sharedPreferences.getString(subCategoryVersionKey);
      if (result != null || result == '') {
        mapData = jsonDecode(result.toString());
      } else {
        mapData = {"version": 0};
      }

      return mapData;
    } catch (e) {

      return mapData;
    }
  }

  static void saveListSubCategory({
    required List<SubCategoryModel> listData,
  }) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString(subCategoryKey, jsonEncode(listData));
      sharedPreferences.getString(subCategoryKey);
    } catch (e) {
 
    }
  }

  static Future<List<SubCategoryModel>> getListSubCategory() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var result = sharedPreferences.getString(subCategoryKey);
      if (result != null || result == '') {
        List<Map<String, dynamic>> listResult = List<Map<String, dynamic>>.from(
          jsonDecode(result.toString()),
        );
        return listResult
            .map((e) => SubCategoryModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  static void saveSubCategoryVersion({required int version}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Map<String, dynamic> mapJson = {'version': version};
      await sharedPreferences.setString(
        subCategoryVersionKey,
        jsonEncode(mapJson),
      );
    } catch (e) {

    }
  }

  // GroupCagetory ============================================================
  static void saveListGroupCategory({
    required List<GroupCategoryModel> listData,
  }) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString(groupCategoryKey, jsonEncode(listData));
      sharedPreferences.getString(groupCategoryKey);

    } catch (e) {

    }
  }

  static Future<List<GroupCategoryModel>> getListGroupCategory() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var result = sharedPreferences.getString(groupCategoryKey);
      if (result != null || result == '') {
        List<Map<String, dynamic>> listResult = List<Map<String, dynamic>>.from(
          jsonDecode(result.toString()),
        );
        return listResult
            .map((e) => GroupCategoryModel.fromJson(jsonBody: e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {

      return [];
    }
  }

  static void saveGroupCategoryVersion({required int version}) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Map<String, dynamic> mapJson = {'version': version};
      await sharedPreferences.setString(
        groupCategoryVersionKey,
        jsonEncode(mapJson),
      );
    } catch (e) {

    }
  }

  static Future<Map<String, dynamic>> getGroupCategoryVersion() async {
    Map<String, dynamic> mapData = {};
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var result = sharedPreferences.getString(groupCategoryVersionKey);
      if (result != null || result == '') {
        mapData = jsonDecode(result.toString());
      } else {
        mapData = {"version": 0};
      }

      return mapData;
    } catch (e) {

      return mapData;
    }
  }
}
