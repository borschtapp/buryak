import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/repository_harness.dart';
import '../../helpers/fake_user.dart';

void main() {
  final harness = setUpRepository(
    (ref, client) => UserRepository(ref: ref, client: client),
    user: User.fromJson(fakeUserJson(refreshToken: 'current-refresh')),
  );

  Future<dynamic> patchBody(Future<void> Function() call) => sentBody(harness.client, .patch, call, response: fakeUserJson());

  test('changing the password keeps the current session by sending its refresh token', () async {
    final body = await patchBody(() => harness.repository.update('user-1', currentPassword: 'old-password', newPassword: 'new-password'));

    expect(body['refresh_token'], 'current-refresh');
  });

  test('changing the email keeps the current session by sending its refresh token', () async {
    final body = await patchBody(() => harness.repository.update('user-1', email: 'new@example.com'));

    expect(body['refresh_token'], 'current-refresh');
  });

  test('renaming does not send the refresh token', () async {
    final body = await patchBody(() => harness.repository.update('user-1', name: 'New Name'));

    expect(body, {'name': 'New Name'});
  });
}
