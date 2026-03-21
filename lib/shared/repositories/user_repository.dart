import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user.dart';
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

  Future<User> update(String id, {String? name, String? email, String? currentPassword, String? newPassword}) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$id',
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
    await sendRequest(method: .delete, path: '/$id');
  }
}
