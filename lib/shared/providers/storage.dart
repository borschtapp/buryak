import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String userKey = 'user';

  static Future<String?> getString(String key) => _storage.read(key: key);

  static Future<void> setString(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<void> remove(String key) => _storage.delete(key: key);
}
