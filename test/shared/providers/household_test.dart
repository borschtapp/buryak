import 'package:buryak/shared/models/household.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/providers/household.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_user.dart';

class MockHouseholdRepository extends Mock implements HouseholdRepository {}

/// Its writes complete on a later event-loop turn, like the real secure-storage
/// channel, so Riverpod flushes the rebuilds the new user scheduled first.
class _FakeAuth extends AuthNotifier {
  _FakeAuth(this._user);

  final User _user;

  @override
  User? build() => _user;

  @override
  Future<void> updateUser(User user) async {
    state = user;
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late MockHouseholdRepository repo;
  late ProviderContainer container;
  const household = Household(id: 'household-1', ownerId: 'user-1', name: 'Home');

  setUp(() {
    repo = MockHouseholdRepository();
    container = ProviderContainer(
      observers: [MutationErrorReporter()],
      overrides: [
        householdRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
      ],
    );
    addTearDown(container.dispose);
    when(() => repo.findOne('household-1', preload: any(named: 'preload'))).thenAnswer((_) async => household);
  });

  test('a failed join is reported and leaves the current household in place', () async {
    when(() => repo.joinHousehold('bad')).thenThrow(GeneralApiException(message: '', statusCode: 404));
    container.listen(householdProvider, (_, _) {});
    await container.read(householdProvider.future);

    await expectLater(
      joinHouseholdMutation.run(container, (tsx) => tsx.get(householdProvider.notifier).joinHousehold('bad')),
      throwsA(isA<GeneralApiException>()),
    );

    expect(container.read(householdProvider), isA<AsyncData<Household?>>().having((s) => s.value, 'value', household));
    expect(container.read(errorHandlerProvider)?.messageKey, ErrorMessageKey.notFound);
  });

  test('joining another household fetches it once', () async {
    final user = User.fromJson(fakeUserJson());
    final container = ProviderContainer(
      overrides: [
        householdRepositoryProvider.overrideWithValue(repo),
        authProvider.overrideWith(() => _FakeAuth(user)),
      ],
    );
    addTearDown(container.dispose);
    when(() => repo.joinHousehold('code')).thenAnswer((_) async => user.copyWith(householdId: 'household-2'));
    when(
      () => repo.findOne('household-2', preload: any(named: 'preload')),
    ).thenAnswer((_) async => const Household(id: 'household-2', ownerId: 'user-2', name: 'Shared'));
    container.listen(householdProvider, (_, _) {});
    await container.read(householdProvider.future);

    await joinHouseholdMutation.run(container, (tsx) => tsx.get(householdProvider.notifier).joinHousehold('code'));

    expect((await container.read(householdProvider.future))?.id, 'household-2');
    verify(() => repo.findOne('household-2', preload: any(named: 'preload'))).called(1);
  });

  test('joining the current household again reloads it', () async {
    final user = User.fromJson(fakeUserJson());
    final container = ProviderContainer(
      overrides: [
        householdRepositoryProvider.overrideWithValue(repo),
        authProvider.overrideWith(() => _FakeAuth(user)),
      ],
    );
    addTearDown(container.dispose);
    when(() => repo.joinHousehold('code')).thenAnswer((_) async => user);
    container.listen(householdProvider, (_, _) {});
    await container.read(householdProvider.future);

    await joinHouseholdMutation.run(container, (tsx) => tsx.get(householdProvider.notifier).joinHousehold('code'));
    await container.read(householdProvider.future);

    verify(() => repo.findOne('household-1', preload: any(named: 'preload'))).called(2);
  });
}
