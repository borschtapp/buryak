import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_auth/flutter_web_auth.dart';

import '../constants.dart';
import 'local_storage.dart';

class UserService {
  static final pb = PocketBase(pocketBaseUrl);

  static final redirectUri =
      kIsWeb ? "${Uri.base.origin}/auth-redirect.html" : "https://borscht.app/auth-redirect.html";
  static final callbackUrlScheme = redirectUri.split(':')[0];

  static bool isLoggedIn() {
    if (pb.authStore.isValid) return true;

    String? token = LocalStorage.instance.getString('token');

    if (token != null) {
      pb.authStore.save(token, null);
      return pb.authStore.isValid;
    }

    return false;
  }

  static Future<dynamic> registerUser(Map<String, dynamic> data) async {
    final record = await pb.collection('users').create(body: data);

    // (optional) send an email verification request
    // await pb.collection('users').requestVerification('test@example.com');

    return record;
  }

  static Future<RecordAuth?> login(String email, String password) async {
    final authData = await pb.collection('users').authWithPassword(email, password);

    // after the above you can also access the auth data from the authStore
    // print(pb.authStore.isValid);
    // print(pb.authStore.token);
    // print(pb.authStore.model.id);

    await LocalStorage.instance.setString('token', authData.token);
    return authData;
  }

  static Future<RecordAuth?> oAuthLogin(String provider) async {
    final authMethods = await pb.collection('users').listAuthMethods();
    final google = authMethods.authProviders.where((am) => am.name.toLowerCase() == provider).first;
    final responseUrl = await FlutterWebAuth.authenticate(
        url: "${google.authUrl}$redirectUri",
        callbackUrlScheme: callbackUrlScheme,
    );

    final parsedUri = Uri.parse(responseUrl);
    final code = parsedUri.queryParameters['code']!;
    final state = parsedUri.queryParameters['state']!;
    if (google.state != state) {
      throw "oops, state mismatch";
    }

    RecordAuth authData = await pb.collection('users')
        .authWithOAuth2("google", code, google.codeVerifier, redirectUri);

    if (authData.record!.data['name'] == null) {
      await pb.collection('users').update(authData.record!.id, body: {
        "name": authData.meta['name'],
        // "avatar": authData.meta['avatarUrl'],
      });

      pb.authStore.model.data['name'] = authData.meta['name'];
      // save(token, model)
    }

    await LocalStorage.instance.setString('token', authData.token);
    return authData;
  }

  static Future<RecordModel> getUserModel() async {
    if (pb.authStore.model == null) {
      RecordAuth authData = await pb.collection('users').authRefresh();
      await LocalStorage.instance.setString('token', authData.token);
    }

    return pb.authStore.model;
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
    pb.authStore.clear();
    await LocalStorage.instance.remove('token');
  }
}
