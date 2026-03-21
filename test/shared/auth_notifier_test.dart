import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/household_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_user.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockHouseholdRepository extends Mock implements HouseholdRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;
  const storage = FlutterSecureStorage();

  setUpAll(() {
    registerFallbackValue(
      User(
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
    mockUserRepository = MockUserRepository();
    container = ProviderContainer(
      overrides: [
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
      when(() => mockUserRepository.login(any(), any())).thenAnswer((_) async => user);

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

      when(() => mockUserRepository.refreshToken(any())).thenAnswer((_) async => newUser);

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

      when(() => mockUserRepository.refreshToken(any())).thenThrow(
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
  });
}
