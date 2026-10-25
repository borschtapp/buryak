import 'package:buryak/features/account/dialog_change_email.dart';
import 'package:buryak/features/account/dialog_change_password.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_user.dart';
import '../../helpers/sheet_opener.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository users;

  setUpAll(() => FlutterSecureStorage.setMockInitialValues({}));

  setUp(() => users = MockUserRepository());

  // The scope owns its container, so a successful save's token-refresh timer is
  // cancelled with the widget tree, before the test checks for pending timers.
  ProviderContainer containerOf(WidgetTester tester) => ProviderScope.containerOf(tester.element(find.text('open', skipOffstage: false)));

  /// Opens the sheet that [show] opens; returns the strings to find its fields by.
  Future<AppLocalizations> open(WidgetTester tester, void Function(BuildContext context) show) async {
    await pumpAndOpen(
      tester,
      show,
      observers: [MutationErrorReporter()],
      overrides: [
        authProvider.overrideWith(FakeAuthNotifier.signedIn),
        userRepositoryProvider.overrideWithValue(users),
      ],
    );
    return AppLocalizations.of(tester.element(find.text('open', skipOffstage: false)));
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('ChangeEmailBottomSheet', () {
    testWidgets('a wrong current password is shown on that field, not reported globally', (tester) async {
      when(
        () => users.update('user-1', email: 'new@example.com', currentPassword: 'wrongpass'),
      ).thenThrow(wrongPasswordError());
      final l10n = await open(tester, ChangeEmailBottomSheet.show);
      final reported = <ErrorMessage?>[];
      containerOf(tester).listen(errorHandlerProvider, (_, next) => reported.add(next));

      await tester.enterText(field(l10n.accountNewEmail), 'new@example.com');
      await tester.enterText(field(l10n.accountCurrentPassword), 'wrongpass');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.byType(ChangeEmailBottomSheet), findsOneWidget);
      expect(find.text(l10n.accountWrongPassword), findsOneWidget);
      expect(reported, isEmpty);

      // Retyping the password clears the error.
      await tester.enterText(field(l10n.accountCurrentPassword), 'secret123');
      await tester.pump();
      expect(find.text(l10n.accountWrongPassword), findsNothing);
    });

    testWidgets('a saved email updates the signed-in user and closes', (tester) async {
      when(
        () => users.update('user-1', email: 'new@example.com', currentPassword: 'secret123'),
      ).thenAnswer((_) async => const User(id: 'user-1', householdId: 'household-1', email: 'new@example.com', name: 'Test User'));
      final l10n = await open(tester, ChangeEmailBottomSheet.show);

      await tester.enterText(field(l10n.accountNewEmail), ' new@example.com ');
      await tester.enterText(field(l10n.accountCurrentPassword), 'secret123');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.byType(ChangeEmailBottomSheet), findsNothing);
      expect(find.text(l10n.accountEmailUpdated), findsOneWidget);
      expect(containerOf(tester).read(authProvider)!.email, 'new@example.com');
    });
  });

  group('ChangePasswordBottomSheet', () {
    testWidgets('a short new password is rejected before anything is sent', (tester) async {
      final l10n = await open(tester, ChangePasswordBottomSheet.show);

      await tester.enterText(field(l10n.accountCurrentPassword), 'secret123');
      await tester.enterText(field(l10n.accountNewPassword), 'short');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.text(l10n.validatorPasswordLength), findsOneWidget);
      verifyZeroInteractions(users);
    });

    testWidgets('a changed password closes the sheet', (tester) async {
      when(
        () => users.update('user-1', currentPassword: 'secret123', newPassword: 'newpassword'),
      ).thenAnswer((_) async => User.fromJson(fakeUserJson()).copyWith(accessToken: null, refreshToken: null));
      final l10n = await open(tester, ChangePasswordBottomSheet.show);

      await tester.enterText(field(l10n.accountCurrentPassword), 'secret123');
      await tester.enterText(field(l10n.accountNewPassword), 'newpassword');
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordBottomSheet), findsNothing);
      expect(find.text(l10n.accountPasswordChanged), findsOneWidget);
    });
  });
}
