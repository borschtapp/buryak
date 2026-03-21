import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import 'repository.dart';

part 'user_repository.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => UserRepository(ref: ref);

/// Auth and user-management repository.
/// Uses [module] = '/api/v1' and includes the full sub-path in each call's [path].
class UserRepository extends Repository {
  const UserRepository({required super.ref}) : super(module: '/api/v1');

  Future<User> login(String email, String password) async {
    final response = await sendRequest(
      method: .post,
      path: '/auth/login',
      authOverride: false,
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
      path: '/auth/register',
      authOverride: false,
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
      path: '/auth/refresh',
      authOverride: false,
      body: {'refresh_token': token},
    );
    final data = ensureMap(response);
    return user.copyWith(
      accessToken: data['access_token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
      householdId: data['household_id']?.toString(),
    );
  }

  Future<void> forgotPassword(String email) async {
    await sendRequest(
      method: .post,
      path: '/auth/forgot-password',
      authOverride: false,
      body: {'email': email},
    );
  }

  Future<void> logout(String refreshToken) async {
    await sendRequest(
      method: .post,
      path: '/auth/logout',
      body: {'refresh_token': refreshToken},
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await sendRequest(
      method: .post,
      path: '/auth/reset-password',
      authOverride: false,
      body: {
        'token': token,
        'new_password': newPassword,
      },
    );
  }

  Future<User> findOne(String id) async {
    final response = await sendRequest(method: .get, path: '/users/$id');
    return User.fromJson(ensureMap(response));
  }

  Future<User> update(String id, {String? name, String? email, String? currentPassword, String? newPassword}) async {
    final response = await sendRequest(
      method: .patch,
      path: '/users/$id',
      body: {
        'name': ?name,
        'email': ?email,
        'current_password': ?currentPassword,
        'new_password': ?newPassword,
      },
    );
    return User.fromJson(ensureMap(response));
  }

  Future<void> delete(String id) async {
    await sendRequest(method: .delete, path: '/users/$id');
  }
}
