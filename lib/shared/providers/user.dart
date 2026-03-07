import 'dart:async';
import 'dart:convert';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/user.dart';
import 'storage.dart';

class UserService {
  static User? _currentUser;
  static Timer? _refreshTimer;

  /// Call once at app startup after WidgetsFlutterBinding.ensureInitialized().
  static Future<void> init() async {
    try {
      final json = await LocalStorage.getString(LocalStorage.userKey);
      if (json != null) {
        _currentUser = User.fromJson(jsonDecode(json));
        if (_currentUser != null) {
          _scheduleTokenRefresh(_currentUser!);
        }
      }
    } catch (e) {
      debugPrint('UserService.init error: $e');
      await logout();
    }
  }

  static bool isLoggedIn() {
    return _currentUser != null && _currentUser!.isValidAccessToken();
  }

  static String getAccessToken() {
    if (_currentUser == null) throw Exception('User not logged in');
    return _currentUser!.accessToken;
  }

  static Future<bool> refreshLogin() async {
    if (_currentUser == null) return false;
    try {
      final refreshed = await UserRepository.refreshToken(_currentUser!);
      await _persist(refreshed);
      return true;
    } catch (e) {
      debugPrint('UserService.refreshLogin error: $e');
      await logout();
      return false;
    }
  }

  static Future<User> registerUser(String name, String email, String password) async {
    final user = await UserRepository.register(name, email, password);
    await _persist(user);
    return user;
  }

  static Future<User> login(String email, String password) async {
    final user = await UserRepository.login(email, password);
    await _persist(user);
    return user;
  }

  static User getUserModel() {
    if (_currentUser != null) return _currentUser!;
    throw Exception('User not found');
  }

  static Future<void> logout() async {
    _cancelTokenRefresh();
    _currentUser = null;
    await LocalStorage.remove(LocalStorage.userKey);
  }

  static Future<void> _persist(User user) async {
    _currentUser = user;
    await LocalStorage.setString(LocalStorage.userKey, jsonEncode(user.toJson()));
    _scheduleTokenRefresh(user);
  }

  static void _scheduleTokenRefresh(User user) {
    _refreshTimer?.cancel();
    try {
      final jwtData = JwtDecoder.decode(user.accessToken);
      final exp = jwtData['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final waitSeconds = exp - now;

      if (waitSeconds <= 0) {
        unawaited(refreshLogin());
        return;
      }

      _refreshTimer = Timer(Duration(seconds: waitSeconds), () async {
        final success = await refreshLogin();
        if (!success) {
          debugPrint('Token refresh failed; user logged out.');
        }
      });
    } catch (e) {
      debugPrint('Failed to schedule token refresh: $e');
    }
  }

  static void _cancelTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}
