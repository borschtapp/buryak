import 'package:buryak/shared/models/household.dart';
import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/providers/household.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockHouseholdRepository extends Mock implements HouseholdRepository {}

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
}
