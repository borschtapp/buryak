import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repository.dart';
import '../repositories/user_repository.dart';
import '../util/logger.dart';

part 'user.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier with WidgetsBindingObserver {
  static const _storage = FlutterSecureStorage();
  static const String _userKey = 'user';

  Timer? _refreshTimer;
  Completer<bool>? _refreshCompleter;
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
      final json = await _storage.read(key: _userKey);
      if (json != null) {
        final user = User.fromJson(jsonDecode(json) as Map<String, dynamic>);
        state = user;
        // If we don't have an access token (which is expected after restart),
        // we need to refresh it.
        if (user.accessToken == null || user.accessToken!.isEmpty) {
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
    if (state == null) return false;

    // Share the result of an in-progress refresh with concurrent callers.
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    // Skip if token is still valid and not forced
    if (!force && state!.isValidAccessToken()) return true;

    _refreshCompleter = Completer<bool>();
    try {
      final refreshed = await ref.read(authRepositoryProvider).refreshToken(state!);
      await _persist(refreshed);
      _refreshCompleter!.complete(true);
      return true;
    } catch (e, s) {
      // If we get an unauthorized error during refresh, log as info and log out
      if (e is GeneralApiException && e.statusCode == 401) {
        logger.i('AuthNotifier.refreshLogin: Session expired (401)');
        await logout();
      } else {
        logger.e('AuthNotifier.refreshLogin error', error: e, stackTrace: s);
      }
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<User> registerUser(String name, String email, String password, {String? inviteCode}) async {
    final user = await ref.read(authRepositoryProvider).register(name, email, password, inviteCode: inviteCode);
    await _persist(user);
    return user;
  }

  Future<User> login(String email, String password) async {
    final user = await ref.read(authRepositoryProvider).login(email, password);
    await _persist(user);
    return user;
  }

  Future<void> updateFromAuthResponse(Map<String, dynamic> data) async {
    final current = state;
    if (current != null) {
      if (data['refresh_token'] == null || (data['refresh_token'] as String).isEmpty) {
        data['refresh_token'] = current.refreshToken;
      }
    }

    final user = User.fromJson(data);
    logger.d('AuthNotifier: updated user householdId: ${user.householdId}');
    await _persist(user);
  }

  Future<void> updateUser(User user) async {
    final current = state;
    final persisted = current != null && (user.refreshToken == null || user.refreshToken!.isEmpty)
        ? user.copyWith(refreshToken: current.refreshToken)
        : user;
    logger.d('AuthNotifier: updated user householdId: ${persisted.householdId}');
    await _persist(persisted);
  }

  Future<void> logout() async {
    _cancelTokenRefresh();
    if (state?.refreshToken != null) {
      try {
        await ref.read(authRepositoryProvider).logout(state!.refreshToken!);
      } catch (e) {
        logger.w('Failed to revoke refresh token on server', error: e);
      }
    }
    state = null;
    await _storage.delete(key: _userKey);
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
    await _storage.write(key: _userKey, value: jsonEncode(userToStore.toFullJson()));
    _scheduleTokenRefresh(user);
  }

  void _scheduleTokenRefresh(User user) {
    _cancelTokenRefresh();
    try {
      final jwtData = User.decodeJwt(user.accessToken!);
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
      logger.w('Failed to schedule token refresh — will retry in 1 minute', error: e);
      _refreshTimer = Timer(const Duration(minutes: 1), () async {
        await refreshLogin(force: true);
      });
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
