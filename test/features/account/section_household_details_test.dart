import 'package:buryak/features/account/section_household_details.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/household.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_user.dart';

class MockHouseholdRepository extends Mock implements HouseholdRepository {}

class FakeAuthNotifier extends AuthNotifier {
  @override
  User? build() => User.fromJson(fakeUserJson());

  @override
  Future<void> init() async {}
}

void main() {
  late MockHouseholdRepository repo;
  late ProviderContainer container;
  final owner = User.fromJson(fakeUserJson());
  final member = User.fromJson({...fakeUserJson(), 'id': 'user-2', 'name': 'Other Member'});

  setUpAll(() => FlutterSecureStorage.setMockInitialValues({}));

  setUp(() {
    repo = MockHouseholdRepository();
    container = ProviderContainer(
      observers: [MutationErrorReporter()],
      overrides: [
        householdRepositoryProvider.overrideWithValue(repo),
        authProvider.overrideWith(FakeAuthNotifier.new),
      ],
    );
    addTearDown(container.dispose);
    when(
      () => repo.findOne('household-1', preload: any(named: 'preload')),
    ).thenAnswer((_) async => Household(id: 'household-1', ownerId: owner.id, name: 'Home', members: [owner, member]));
  });

  testWidgets('a failed member removal is reported and keeps the member', (tester) async {
    when(() => repo.removeMember('household-1', 'user-2')).thenThrow(GeneralApiException(message: '', statusCode: 403));
    final errors = <ErrorMessageKey?>[];
    container.listen(errorHandlerProvider, (_, next) => errors.add(next?.messageKey));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: SingleChildScrollView(child: HouseholdDetails())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.tap(find.byIcon(Icons.person_remove));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.householdRemoveMemberConfirm));
    await tester.pumpAndSettle();

    expect(errors, [ErrorMessageKey.noPermission]);
    expect(find.text('Other Member'), findsOneWidget);
  });
}
