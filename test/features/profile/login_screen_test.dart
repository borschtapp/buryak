// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:buryak/features/profile/screen_login.dart';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/fake_user.dart';
import 'package:buryak/shared/models/user.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    FlutterSecureStorage.setMockInitialValues({});
  });

  Widget createLoginScreen() {
    return ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('LoginScreen initial state', (tester) async {
    await tester.pumpWidget(createLoginScreen());

    expect(find.text('Login to your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login now'), findsOneWidget);
  });

  testWidgets('validation fails for empty fields', (tester) async {
    await tester.pumpWidget(createLoginScreen());

    await tester.tap(find.text('Login now'));
    await tester.pump();

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters.'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(createLoginScreen());

    final passwordFinder = find.widgetWithText(TextFormField, 'Password');
    TextField getTextField() => tester.widget<TextField>(
      find.descendant(of: passwordFinder, matching: find.byType(TextField)),
    );

    expect(getTextField().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(getTextField().obscureText, isFalse);
  });

  testWidgets('successful login calls repository', (tester) async {
    final user = User.fromJson(fakeUserJson());
    when(() => mockUserRepository.login(any(), any())).thenAnswer((_) async => user);

    await tester.pumpWidget(createLoginScreen());

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.text('Login now'));
    await tester.pump();

    verify(() => mockUserRepository.login('test@example.com', 'password123')).called(1);
  });

  testWidgets('failed login shows snackbar', (tester) async {
    when(() => mockUserRepository.login(any(), any())).thenThrow(GeneralApiException(message: 'Invalid credentials'));

    await tester.pumpWidget(createLoginScreen());

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.text('Login now'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Invalid credentials'), findsOneWidget);
  });

  testWidgets('has correct autofill hints', (tester) async {
    await tester.pumpWidget(createLoginScreen());

    expect(find.byType(AutofillGroup), findsOneWidget);

    final emailField = tester.widget<TextField>(
      find.descendant(of: find.widgetWithText(TextFormField, 'Email'), matching: find.byType(TextField)),
    );
    expect(emailField.autofillHints, contains(AutofillHints.email));
    expect(emailField.keyboardType, TextInputType.emailAddress);

    final passwordField = tester.widget<TextField>(
      find.descendant(of: find.widgetWithText(TextFormField, 'Password'), matching: find.byType(TextField)),
    );
    expect(passwordField.autofillHints, contains(AutofillHints.password));
  });
}
