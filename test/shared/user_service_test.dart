import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/providers/storage.dart';

import '../helpers/fake_user.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('UserService.init', () {
    test('sets _currentUser from secure storage when valid user present', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: jsonEncode(fakeUserJson()),
      });

      await UserService.init();

      expect(UserService.isLoggedIn(), isTrue);
    });

    test('leaves user null when storage is empty', () async {
      await UserService.init();
      expect(UserService.isLoggedIn(), isFalse);
    });

    test('calls logout when stored JSON is malformed', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: 'not-valid-json',
      });

      await UserService.init();
      expect(UserService.isLoggedIn(), isFalse);
    });
  });

  group('UserService.isLoggedIn', () {
    test('returns false when no user is cached', () async {
      await UserService.init();
      expect(UserService.isLoggedIn(), isFalse);
    });

    test('returns false when cached user has expired token', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: jsonEncode(fakeUserJson(accessToken: kExpiredJwt)),
      });

      await UserService.init();
      expect(UserService.isLoggedIn(), isFalse);
    });

    test('returns true when cached user has valid token', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: jsonEncode(fakeUserJson(accessToken: kFutureJwt)),
      });

      await UserService.init();
      expect(UserService.isLoggedIn(), isTrue);
    });
  });

  group('UserService.getAccessToken', () {
    test('returns token when user is cached', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: jsonEncode(fakeUserJson()),
      });

      await UserService.init();
      expect(UserService.getAccessToken(), equals(kFutureJwt));
    });

    test('throws when no user is cached', () async {
      await UserService.init();
      expect(() => UserService.getAccessToken(), throwsException);
    });
  });

  group('UserService.logout', () {
    test('clears user from memory and storage', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: jsonEncode(fakeUserJson()),
      });

      await UserService.init();
      expect(UserService.isLoggedIn(), isTrue);

      await UserService.logout();

      expect(UserService.isLoggedIn(), isFalse);
      expect(() => UserService.getAccessToken(), throwsException);
    });

    test('storage key is removed after logout', () async {
      FlutterSecureStorage.setMockInitialValues({
        LocalStorage.userKey: jsonEncode(fakeUserJson()),
      });

      await UserService.init();
      await UserService.logout();

      final stored = await LocalStorage.getString(LocalStorage.userKey);
      expect(stored, isNull);
    });
  });
}
