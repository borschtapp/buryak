import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
import '../providers/user.dart';
import 'repository.dart';

part 'user_repository.g.dart';

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) => UserRepository(ref: ref, client: ref.watch(httpClientProvider));

class UserRepository extends Repository {
  const UserRepository({required super.ref, super.client}) : super(module: '/api/v1/users');

  Future<User> findOne(String id) async {
    final response = await sendRequest(method: .get, path: '/$id');
    return User.fromJson(ensureMap(response));
  }

  /// Changing the email or password revokes every other session of the user,
  /// so the current refresh token is sent along to keep this one signed in.
  Future<User> update(String id, {String? name, String? email, String? currentPassword, String? newPassword}) async {
    final refreshToken = email != null || newPassword != null ? ref.read(authProvider)?.refreshToken : null;
    final response = await sendRequest(
      method: .patch,
      path: '/$id',
      body: {
        'name': ?name,
        'email': ?email,
        'current_password': ?currentPassword,
        'new_password': ?newPassword,
        if (refreshToken != null && refreshToken.isNotEmpty) 'refresh_token': refreshToken,
      },
    );
    return User.fromJson(ensureMap(response));
  }

  Future<void> delete(String id) async {
    await sendRequest(method: .delete, path: '/$id');
  }
}
