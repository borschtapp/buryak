import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/user_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_user.dart';

class MockClient extends Mock implements http.Client {}

class FakeAuthNotifier extends AuthNotifier {
  @override
  User? build() => User.fromJson(fakeUserJson(refreshToken: 'current-refresh'));

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshLogin({bool force = false}) async => true;
}

void main() {
  late MockClient mockClient;
  late UserRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(Uri.parse('https://example.com'));
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    mockClient = MockClient();
    container = ProviderContainer(overrides: [authProvider.overrideWith(FakeAuthNotifier.new)]);
    repository = UserRepository(ref: container.read(Provider<Ref>((ref) => ref)), client: mockClient);
  });

  tearDown(() => container.dispose());

  Future<Map<String, dynamic>> sentBody(Future<void> Function() call) async {
    when(
      () => mockClient.patch(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async => http.Response(jsonEncode(fakeUserJson()), 200));
    await call();
    final body = verify(
      () => mockClient.patch(
        any(),
        headers: any(named: 'headers'),
        body: captureAny(named: 'body'),
      ),
    ).captured.single;
    return jsonDecode(body as String) as Map<String, dynamic>;
  }

  test('changing the password keeps the current session by sending its refresh token', () async {
    final body = await sentBody(() => repository.update('user-1', currentPassword: 'old-password', newPassword: 'new-password'));

    expect(body['refresh_token'], 'current-refresh');
  });

  test('changing the email keeps the current session by sending its refresh token', () async {
    final body = await sentBody(() => repository.update('user-1', email: 'new@example.com'));

    expect(body['refresh_token'], 'current-refresh');
  });

  test('renaming does not send the refresh token', () async {
    final body = await sentBody(() => repository.update('user-1', name: 'New Name'));

    expect(body, {'name': 'New Name'});
  });
}
