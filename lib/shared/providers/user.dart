import 'dart:async';
import 'dart:convert';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import 'storage.dart';
import '../util/logger.dart';

part 'user.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier with WidgetsBindingObserver {
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  bool _observerAdded = false;

  @override
  User? build() {
    if (!_observerAdded) {
      WidgetsBinding.instance.addObserver(this);
      _observerAdded = true;
    }

    ref.onDispose(() {
      _cancelTokenRefresh();
      WidgetsBinding.instance.removeObserver(this);
    });
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _cancelTokenRefresh();
    } else if (state == AppLifecycleState.resumed) {
      if (this.state != null) {
        // When resuming, checked if token is expired and refresh if needed.
        // This handles cases where the app was in background for a long time.
        if (!this.state!.isValidAccessToken()) {
          unawaited(refreshLogin(force: true));
        } else {
          _scheduleTokenRefresh(this.state!);
        }
      }
    }
  }

  Future<void> init() async {
    _cancelTokenRefresh();
    try {
      final json = await LocalStorage.getString(LocalStorage.userKey);
      if (json != null) {
        final user = User.fromJson(jsonDecode(json) as Map<String, dynamic>);
        state = user;
        // If we don't have an access token (which is expected after restart),
        // we need to refresh it.
        if (user.accessToken.isEmpty) {
          await refreshLogin(force: true);
        } else {
          _scheduleTokenRefresh(user);
        }
      }
    } catch (e, s) {
      logger.e('AuthNotifier.init error', error: e, stackTrace: s);
      await logout();
    }
  }

  // Removed isLoggedIn and accessToken getters to comply with avoid_public_notifier_properties lint.
  // Use the AuthStateX extension on the provider state instead.

  /// Refreshes the login token. If [force] is true, it refreshes regardless of expiration.
  Future<bool> refreshLogin({bool force = false}) async {
    if (state == null || _isRefreshing) return false;

    // Skip if token is still valid and not forced
    if (!force && state!.isValidAccessToken()) return true;

    _isRefreshing = true;
    try {
      final refreshed = await ref.read(userRepositoryProvider).refreshToken(state!);
      await _persist(refreshed);
      return true;
    } catch (e, s) {
      // If we get an unauthorized error during refresh, log as info and log out
      if (e is GeneralApiException && e.statusCode == 401) {
        logger.i('AuthNotifier.refreshLogin: Session expired (401)');
        await logout();
      } else {
        logger.e('AuthNotifier.refreshLogin error', error: e, stackTrace: s);
      }
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<User> registerUser(String name, String email, String password) async {
    final user = await ref.read(userRepositoryProvider).register(name, email, password);
    await _persist(user);
    return user;
  }

  Future<User> login(String email, String password) async {
    final user = await ref.read(userRepositoryProvider).login(email, password);
    await _persist(user);
    return user;
  }

  Future<void> logout() async {
    _cancelTokenRefresh();
    state = null;
    await LocalStorage.remove(LocalStorage.userKey);
  }

  Future<void> deleteAccount() async {
    final id = state?.id;
    if (id == null) return;
    await ref.read(userRepositoryProvider).delete(id);
    await logout();
  }

  Future<void> _persist(User user) async {
    state = user;
    // Strip access token before persisting to storage
    final userToStore = user.copyWith(accessToken: '');
    await LocalStorage.setString(LocalStorage.userKey, jsonEncode(userToStore.toFullJson()));
    _scheduleTokenRefresh(user);
  }

  void _scheduleTokenRefresh(User user) {
    _cancelTokenRefresh();
    try {
      final jwtData = JwtDecoder.decode(user.accessToken);
      final exp = (jwtData['exp'] as int) * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Refresh 60 seconds before expiration
      final refreshTimestamp = exp - 60000;
      final waitMs = refreshTimestamp - now;

      if (waitMs <= 0) {
        unawaited(refreshLogin());
        return;
      }

      _refreshTimer = Timer(Duration(milliseconds: waitMs), () async {
        await refreshLogin();
      });
    } catch (e) {
      logger.w('Failed to schedule token refresh - logging out', error: e);
      unawaited(logout());
    }
  }

  void _cancelTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}

extension AuthStateX on User? {
  bool get isLoggedIn => this != null && this!.isValidAccessToken();
}
