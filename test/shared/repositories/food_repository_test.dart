import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/food_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

class FakeAuthNotifier extends AuthNotifier {
  @override
  User? build() => null;

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshLogin({bool force = false}) async => true;
}

void main() {
  late MockClient mockClient;
  late FoodRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(Uri.parse('https://example.com'));
    FlutterSecureStorage.setMockInitialValues({});
  });

  setUp(() {
    mockClient = MockClient();
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(FakeAuthNotifier.new),
      ],
    );
    repository = FoodRepository(
      ref: container.read(Provider<Ref>((ref) => ref)),
      client: mockClient,
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FoodRepository.update', () {
    Future<Map<String, dynamic>> sentBody(Future<void> Function() call) async {
      when(
        () => mockClient.patch(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode({'id': 'f1', 'slug': 'onion', 'name': 'Onion'}), 200));
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

    test('leaves out fields that were not passed', () async {
      final body = await sentBody(() => repository.update('f1', pantry: true));

      expect(body, {'pantry': true});
    });

    test('sends a new description', () async {
      final body = await sentBody(() => repository.update('f1', description: 'Yellow, for frying'));

      expect(body, {'description': 'Yellow, for frying'});
    });

    test('an empty description sends an explicit null', () async {
      final body = await sentBody(() => repository.update('f1', description: ''));

      expect(body, {'description': null});
    });
  });
}
