import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/repository.dart';

import 'fake_user.dart';

/// Auth signed in as [user], or signed out, that never touches storage, refreshes
/// or signs out.
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier([this.user]);

  /// Signed in as the [fakeUserJson] user.
  FakeAuthNotifier.signedIn() : user = User.fromJson(fakeUserJson());

  final User? user;

  @override
  User? build() {
    super.build(); // keeps the dispose hook that cancels the token refresh
    return user;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshLogin({bool force = false}) async => true;
}

/// What the server answers a credential change whose current password is wrong.
FieldsApiException wrongPasswordError() => FieldsApiException(
  message: 'Current password is incorrect',
  fields: {'current_password': 'Current password is incorrect'},
  statusCode: 422,
);
