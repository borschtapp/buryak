import 'dart:convert';

import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
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

  static Future<User?> login(String email, String password) async {
    final user = await UserRepository.login(email, password);
    if (user != null) {
      await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
      return user;
    }
    return null;
  }

  // static Future<RecordAuth?> googleLogin() async {
  //   GoogleSignIn googleSignIn = GoogleSignIn(
  //     scopes: [
  //       'https://www.googleapis.com/auth/userinfo.email',
  //       'https://www.googleapis.com/auth/userinfo.profile',
  //     ],
  //   );
  //
  //   try {
  //     var account = await googleSignIn.signIn();
  //
  //     if (account != null) {
  //       var auth = await account.authentication;
  //
  //       if (auth.idToken != null) {
  //         print(auth.idToken!);
  //       }
  //     }
  //   } catch (error) {
  //     print(error);
  //   }
  //   return null;
  // }
  //
  // static Future<RecordAuth?> oAuthLogin(String provider) async {
  //   final authMethods = await pb.collection('users').listAuthMethods();
  //   final google = authMethods.authProviders.where((am) => am.name.toLowerCase() == provider).first;
  //   final responseUrl = await FlutterWebAuth.authenticate(
  //     url: "${google.authUrl}$redirectUri",
  //     callbackUrlScheme: callbackUrlScheme,
  //   );
  //
  //   final parsedUri = Uri.parse(responseUrl);
  //   final code = parsedUri.queryParameters['code']!;
  //   final state = parsedUri.queryParameters['state']!;
  //   if (google.state != state) {
  //     throw "oops, state mismatch";
  //   }
  //
  //   RecordAuth authData = await pb.collection('users')
  //       .authWithOAuth2Code("google", code, google.codeVerifier, redirectUri);
  //
  //   if (authData.record!.data['name'] == null) {
  //     await pb.collection('users').update(authData.record!.id, body: {
  //       "name": authData.meta['name'],
  //       // "avatar": authData.meta['avatarUrl'],
  //     });
  //
  //     pb.authStore.model.data['name'] = authData.meta['name'];
  //     // save(token, model)
  //   }
  //
  //   await LocalStorage.setString('token', authData.token);
  //   return authData;
  // }

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

// Future<dynamic> updateUserProfile({
//   required String accessToken,
//   required Map<String, dynamic> data,
// }) async {
//   try {
//     Response response = await _dio.put(
//       'https://api.loginradius.com/identity/v2/auth/account',
//       data: data,
//       queryParameters: {'apikey': ApiSecret.apiKey},
//       options: Options(
//         headers: {'Authorization': 'Bearer $accessToken'},
//       ),
//     );
//     return response.data;
//   } on DioError catch (e) {
//     return e.response!.data;
//   }
// }

  static logout() async {
    await LocalStorage.remove(LocalStorage.userKey);
  }
}
