import 'dart:convert';
import 'dart:io';
import 'package:findup_mvvm/Data/models/user_model.dart';
import 'package:findup_mvvm/Data/view_models/user_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static String apiToken = "";
  static UserModel? userModel;


  Future<String> getLocalImage(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory("${directory.path}/cached_images");

    // Create folder if missing
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final filename = url.split('/').last;
    final filePath = "${folder.path}/$filename";
    final file = File(filePath);

    // If file already exists → use it
    if (await file.exists()) {
      return file.path;
    }

    // Otherwise download and save
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw "Failed to download image";
      }
    } catch (e) {
      throw "Error caching image: $e";
    }
  }

  // Save a Map<String, dynamic>
  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(value);
    await prefs.setString(key, jsonString);
  }

  // Load a Map<String, dynamic>
  static Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // Save a List<Map<String, dynamic>>
  static Future<void> saveMapList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(list);
    await prefs.setString(key, jsonString);
  }

  // Load a List<Map<String, dynamic>>
  static Future<List<Map<String, dynamic>>> getMapList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List decodedList = jsonDecode(jsonString);
    return decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Remove key
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear all local data
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
