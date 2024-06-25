import 'dart:convert';

import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_platform/universal_platform.dart';

import '../models/user.dart';
import 'storage.dart';

class UserService {
  static final redirectUri = UniversalPlatform.isWeb ? "${Uri.base.origin}/auth-redirect.html" : "https://borscht.app/auth-redirect.html";
  static final callbackUrlScheme = redirectUri.split(':')[0];

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
    } catch (e) {}

    logout();
    return false;
  }

  static Future<User> registerUser(String name, email, password) async {
    final user = await UserRepository.register(name, email, password);
    await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
    return user;
  }

  static Future<User> login(String email, String password) async {
    final user = await UserRepository.login(email, password);
    await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
    return user;
  }

  static Future<User?> googleLogin() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    try {
      var account = await googleSignIn.signIn();

      if (account != null) {
        var auth = await account.authentication;
        final user = await UserRepository.oauthLogin('google', auth.accessToken);
        await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
        return user;
      }
    } catch (error) {
      print(error);
    }
    return null;
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

  static logout() async {
    await LocalStorage.remove(LocalStorage.userKey);
  }
}
