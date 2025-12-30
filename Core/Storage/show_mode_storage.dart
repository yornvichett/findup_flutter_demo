import 'package:shared_preferences/shared_preferences.dart';

class ShowModeStorage {
  String keyModel = "mode";
  static saveModeCache({required String mode}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var val = sharedPreferences.getString("mode");

    sharedPreferences.setString('mode', mode);
  }

  static Future<String> getModeCache() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var val = sharedPreferences.getString("mode");
    if (val == null) {
      return '';
    } else {
      return val.toString();
    }
  }
}
