import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late final SharedPreferences _instance;

  static const String userKey = 'user';

  static bool _init = false;
  static Future init() async {
    if (_init) return;
    _instance = await SharedPreferences.getInstance();
    _init = true;
    return _instance;
  }

  static String? getString(String key) {
    if (!_init) return null;
    return _instance.getString(key);
  }

  static Future<bool> setString(String key, String value) {
    if (!_init) return Future.value(false);
    return _instance.setString(key, value);
  }

  static Future<bool> remove(String key) {
    if (!_init) return Future.value(false);
    return _instance.remove(key);
  }
}
