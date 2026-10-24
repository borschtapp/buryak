import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/fake_user.dart';
import '../../helpers/signed_out.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late User user;
  late int builds;
  late Provider<Session> scoped;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    user = User.fromJson(fakeUserJson());
    builds = 0;
    scoped = Provider<Session>((ref) {
      builds++;
      return ref.watchSession();
    });
  });

  void signIn(User u) => container.read(authProvider.notifier).state = u;

  test('watchSession throws SignedOutError while signed out', () {
    expect(() => container.read(scoped), throwsSignedOut);
  });

  test('a token refresh keeps the session, so scoped providers keep their cache', () {
    signIn(user);
    container.listen(scoped, (_, _) {});
    expect(container.read(scoped), (userId: 'user-1', householdId: 'household-1'));

    signIn(user.copyWith(accessToken: generateFakeJwt(expiresIn: const Duration(hours: 1))));
    container.read(scoped);

    expect(builds, 1);
  });

  test('switching household or signing out rebuilds scoped providers', () {
    signIn(user);
    container.listen(scoped, (_, _) {}, onError: (_, _) {});
    container.read(scoped);

    signIn(user.copyWith(householdId: 'household-2'));
    expect(container.read(scoped).householdId, 'household-2');

    signIn(user.copyWith(id: 'user-2'));
    expect(container.read(scoped).userId, 'user-2');

    container.read(authProvider.notifier).state = null;
    expect(() => container.read(scoped), throwsSignedOut);
    expect(builds, 4);
  });
}
