import 'dart:convert';

import 'package:http/http.dart';

import '../models/user.dart';
import 'repository.dart';

class UserRepository {
  static Future<User> login(String email, password) async {
    Response response = await post(buildUri('/login'),
        headers: buildHeaders(),
        body: jsonEncode({'email': email, 'password': password}));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<User> oauthLogin(String provider, token) async {
    Response response = await post(buildUri('/oauth/login'),
        headers: buildHeaders(),
        body: jsonEncode({'provider': provider, 'token': token}));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<User> register(String name, email, password) async {
    Response response = await post(buildUri('/users'),
        headers: buildHeaders(),
        body: jsonEncode({'name': name, 'email': email, 'password': password}));

    final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      case 400:
        final json = jsonDecode(response.body);
        throw handleFormErrors(json);
      case 300:
      case 500:
      default:
        throw FormGeneralException(message: 'Error contacting the server!');
    }
  }

  static Future<User> refreshToken(User user) async {
    Response response = await post(buildUri('/token/refresh'),
        headers: buildHeaders(),
        body: jsonEncode({'refresh_token': user.refreshToken}));

        final statusType = (response.statusCode / 100).floor() * 100;
    switch (statusType) {
      case 200:
        final json = jsonDecode(response.body);
        user.accessToken = json['access_token'];
        user.refreshToken = json['refresh_token'];
        return user;
      case 400:
      case 300:
      case 500:
      default:
        throw Exception('Error contacting the server!');
    }
  }
}
