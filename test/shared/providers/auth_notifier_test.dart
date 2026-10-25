import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/auth_repository.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_auth.dart';
import '../../helpers/fake_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHouseholdRepository extends Mock implements HouseholdRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;
  const storage = FlutterSecureStorage();

  setUpAll(() {
    registerFallbackValue(
      const User(
        id: '',
        householdId: '',
        name: '',
        email: '',
        accessToken: '',
        refreshToken: '',
      ),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        householdRepositoryProvider.overrideWithValue(MockHouseholdRepository()),
      ],
    );
    FlutterSecureStorage.setMockInitialValues({});
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test('init loads user from storage', () async {
      final userJson = fakeUserJson();
      FlutterSecureStorage.setMockInitialValues({
        'user': jsonEncode(userJson),
      });

      await container.read(authProvider.notifier).init();

      final state = container.read(authProvider);
      expect(state, isNotNull);
      expect(state!.email, equals(userJson['email']));
    });

    test('login persists user and updates state', () async {
      final userJson = fakeUserJson();
      final user = User.fromJson(userJson);
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((_) async => user);

      await container.read(authProvider.notifier).login('test@example.com', 'password');

      expect(container.read(authProvider), equals(user));
      final storedData = await storage.read(key: 'user');
      expect(storedData, isNotNull);
      final storedUser = jsonDecode(storedData!);
      expect(storedUser['email'], equals(user.email));
      // Verify accessToken is stripped in storage
      expect(storedUser['access_token'], isEmpty);
    });

    test('logout clears state and storage', () async {
      when(() => mockAuthRepository.logout(any())).thenAnswer((_) async {});

      // Seed state
      final user = User.fromJson(fakeUserJson());
      FlutterSecureStorage.setMockInitialValues({
        'user': jsonEncode(user.toFullJson()),
      });
      await container.read(authProvider.notifier).init();

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider), isNull);
      final storedData = await storage.read(key: 'user');
      expect(storedData, isNull);
    });

    test('refreshLogin updates state on success', () async {
      final oldUser = User.fromJson(fakeUserJson(accessToken: kExpiredJwt));
      final newUser = oldUser.copyWith(accessToken: kFutureJwt);

      when(() => mockAuthRepository.refreshToken(any())).thenAnswer((_) async => newUser);

      // Seed state
      FlutterSecureStorage.setMockInitialValues({
        'user': jsonEncode(oldUser.toFullJson()),
      });
      await container.read(authProvider.notifier).init();

      // Since the token was expired, init() should have already triggered a refresh.
      // We might need to wait for it or just check the state.
      // refreshLogin is unawaited in _scheduleTokenRefresh, so we use pump or wait a bit.
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider)!.accessToken, equals(kFutureJwt));
    });

    test('refreshLogin logs out on 401 error', () async {
      final oldUser = User.fromJson(fakeUserJson(accessToken: kExpiredJwt));

      when(() => mockAuthRepository.logout(any())).thenAnswer((_) async {});
      when(() => mockAuthRepository.refreshToken(any())).thenThrow(
        GeneralApiException(message: 'Unauthorized', statusCode: 401),
      );

      // Seed state
      FlutterSecureStorage.setMockInitialValues({
        'user': jsonEncode(oldUser.toFullJson()),
      });
      await container.read(authProvider.notifier).init();

      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider), isNull);
    });

    group('profile changes', () {
      Future<void> signIn() async {
        FlutterSecureStorage.setMockInitialValues({'user': jsonEncode(User.fromJson(fakeUserJson()).toFullJson())});
        await container.read(authProvider.notifier).init();
      }

      test('a new email is stored, and this session keeps its tokens', () async {
        await signIn();
        // The response is the user without tokens.
        when(
          () => mockUserRepository.update('user-1', email: 'new@example.com', currentPassword: 'secret123'),
        ).thenAnswer((_) async => const User(id: 'user-1', householdId: 'household-1', email: 'new@example.com', name: 'Test User'));

        await container.read(authProvider.notifier).changeEmail('new@example.com', currentPassword: 'secret123');

        final user = container.read(authProvider)!;
        expect(user.email, 'new@example.com');
        expect(user.accessToken, kFutureJwt);
        expect(user.refreshToken, 'refresh-token-abc');
        final stored = jsonDecode((await storage.read(key: 'user'))!) as Map<String, dynamic>;
        expect((stored['email'], stored['refresh_token']), ('new@example.com', 'refresh-token-abc'));
      });

      test('a rejected current password is a WrongPasswordException and changes nothing', () async {
        await signIn();
        when(
          () => mockUserRepository.update('user-1', currentPassword: 'wrong', newPassword: 'newpassword'),
        ).thenThrow(wrongPasswordError());

        await expectLater(
          container.read(authProvider.notifier).changePassword(currentPassword: 'wrong', newPassword: 'newpassword'),
          throwsA(isA<WrongPasswordException>()),
        );
        expect(container.read(authProvider)!.email, 'test@example.com');
      });

      test('a new name does not touch the session', () async {
        await signIn();
        final sessions = <Session?>[];
        container.listen(sessionProvider, (_, next) => sessions.add(next));
        when(
          () => mockUserRepository.update('user-1', name: 'Chef'),
        ).thenAnswer((_) async => const User(id: 'user-1', householdId: 'household-1', email: 'test@example.com', name: 'Chef'));

        await container.read(authProvider.notifier).changeName('Chef');

        expect(container.read(authProvider)!.name, 'Chef');
        expect(sessions, isEmpty, reason: 'per-user caches must survive a rename');
      });

      test('an email matching the cached one is still sent, so the server checks the password', () async {
        await signIn();
        when(
          () => mockUserRepository.update('user-1', email: 'test@example.com', currentPassword: 'wrong'),
        ).thenThrow(wrongPasswordError());

        await expectLater(
          container.read(authProvider.notifier).changeEmail('test@example.com', currentPassword: 'wrong'),
          throwsA(isA<WrongPasswordException>()),
        );
      });

      test('a name matching the cached one is still sent, since another device may have changed it', () async {
        await signIn();
        when(
          () => mockUserRepository.update('user-1', name: 'Test User'),
        ).thenAnswer((_) async => const User(id: 'user-1', householdId: 'household-1', email: 'test@example.com', name: 'Test User'));

        await container.read(authProvider.notifier).changeName('Test User');

        verify(() => mockUserRepository.update('user-1', name: 'Test User')).called(1);
      });
    });
  });
}
