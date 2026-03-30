import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import 'repository.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(ref: ref, client: ref.watch(httpClientProvider));

class AuthRepository extends Repository {
  const AuthRepository({required super.ref, super.client}) : super(module: '/api/v1/auth', isAuth: false);

  Future<User> login(String email, String password) async {
    final response = await sendRequest(
      method: .post,
      path: '/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    return User.fromJson(ensureMap(response));
  }

  Future<User> register(String name, String email, String password, {String? inviteCode}) async {
    final response = await sendRequest(
      method: .post,
      path: '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'invite_code': ?inviteCode,
      },
    );
    return User.fromJson(ensureMap(response));
  }

  Future<User> refreshToken(User user) async {
    final token = user.refreshToken;
    if (token == null || token.isEmpty) throw StateError('No refresh token available');

    final response = await sendRequest(
      method: .post,
      path: '/refresh',
      body: {'refresh_token': token},
    );
    final data = ensureMap(response);
    return user.copyWith(
      accessToken: data['access_token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      householdId: data['household_id']?.toString() ?? user.householdId,
    );
  }

  Future<void> forgotPassword(String email) async {
    await sendRequest(
      method: .post,
      path: '/forgot-password',
      body: {'email': email},
    );
  }

  Future<void> logout(String refreshToken) async {
    await sendRequest(
      method: .post,
      path: '/logout',
      authOverride: false,
      body: {'refresh_token': refreshToken},
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await sendRequest(
      method: .post,
      path: '/reset-password',
      body: {
        'token': token,
        'new_password': newPassword,
      },
    );
  }
}
