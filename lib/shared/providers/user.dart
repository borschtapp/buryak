import 'package:buryak/shared/repositories/user_repository.dart';

import '../models/user.dart';
import 'storage.dart';
import 'dart:convert';

class UserService {
  static bool isLoggedIn() {
    String? json = LocalStorage.getString(LocalStorage.userKey);

    if (json != null) {
      return User.fromJson(jsonDecode(json)).isValidAccessToken();
    }

    return false;
  }

  static Future<bool> refreshLogin() async {
    try {
      String? json = LocalStorage.getString(LocalStorage.userKey);

      if (json != null) {
        User user = User.fromJson(jsonDecode(json));
        user = await UserRepository.refreshToken(user);
        await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
        return true;
      }
    } catch (e) {
      // ignore
    }

    logout();
    return false;
  }

  static Future<User> registerUser(String name, String email, String password) async {
    final user = await UserRepository.register(name, email, password);
    await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
    return user;
  }

  static Future<User> login(String email, String password) async {
    final user = await UserRepository.login(email, password);
    await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
    return user;
  }

  static Future<User> getUserModel() async {
    String? json = LocalStorage.getString(LocalStorage.userKey);

    if (json != null) {
      return User.fromJson(jsonDecode(json));
    }

    throw Exception('User not found');
  }

  static String getAccessToken() {
    String? json = LocalStorage.getString(LocalStorage.userKey);

    if (json != null) {
      return User.fromJson(jsonDecode(json)).accessToken;
    }

    throw Exception('User not found');
  }

  static Future<void> logout() async {
    await LocalStorage.remove(LocalStorage.userKey);
  }
}
