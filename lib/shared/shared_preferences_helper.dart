import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static final String lastAppTheme = 'lastAppTheme';

  static Future<int> getLastAppTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastAppTheme) ?? 0;
  }

  static Future<bool> setLastAppTheme(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(lastAppTheme, value);
  }
}
