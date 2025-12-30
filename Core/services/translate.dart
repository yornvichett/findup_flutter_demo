import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Translator {
  static Map<String, String> _translations = {};

  /// Load JSON from assets
  static Future<void> load(String path) async {
    String jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    
    _translations = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  /// Translate function
  static String translate(String key) {
    return _translations[key] ?? key;
  }
}
