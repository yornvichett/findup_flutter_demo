import 'dart:convert';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefStorage {
  String keyFCMToken = "key_fcm_token";
  String langKey = "keyLanStorage";

  String keyHomeRefreshVersion="keyHomeRefreshVersion";
  String keyGroupCategoryRefreshVersion="keyGroupCategoryRefreshVersion";
  String keyGroupPlaceRefreshVersion="keyGroupPlaceRefreshVersion";

  Future<void> setLanguages({
    required Map<String, dynamic> mapData,
    required String key,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(key, jsonEncode(mapData));
    } catch (e) {

    }
  }

  // save refersh version
  // void saveRefersVersion({required int version})async{
  //   final prefs = await SharedPreferences.getInstance();
  //     prefs.setString(key, jsonEncode(mapData));
  // }
  // save version
  // save list group category to local
  

  Future<Map<String, dynamic>> initLanguages({
    required String key,
  }) async {
    String result = "";
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(key) != null) {
        result = prefs.getString(key)!;
      } else {
        result = '{}';
      }
    } catch (e) {
 
    }
    return Map<String, dynamic>.of(jsonDecode(result));
  }

  Future<void> saveFCMToken({required String fcmToken}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyFCMToken, fcmToken);
  
    } catch (e) {

    }
  }

  Future<String> getFCMToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String getToken = prefs.getString(keyFCMToken)!;
 
      return getToken;
    } catch (e) {
   
      return '';
    }
  }

  Future<List<String>> saveProductReportID({
    required String key,
    required String value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String defaultVal = await prefs.getString(key)!;
      if (defaultVal == 'null') {
        await prefs.setString(key, '$value,');
      } else {
        defaultVal += value;
        await prefs.setString(key, '$defaultVal,');
      }

      await prefs.getString('rp')!;


      return [];
    } catch (e) {

      return [];
    }
  }

  Future<void> clearReportID({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('a', '');
    } catch (e) {

    }
  }
}
