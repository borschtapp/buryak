import 'dart:convert';

import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/import_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';

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
  late ImportRepository repository;
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
    repository = ImportRepository(
      ref: container.read(Provider<Ref>((ref) => ref)),
      client: mockClient,
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ImportRepository', () {
    test('import returns ImportResult with recipe', () async {
      final responseBody = jsonEncode({
        'created': true,
        'recipe': fakeRecipeJson(id: 'imported-id'),
        'feed': null,
      });

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await repository.import('https://example.com/recipe');

      expect(result.recipe?.id, 'imported-id');
      expect(result.created, true);
    });

    test('import returns ImportResult with feed', () async {
      final responseBody = jsonEncode({
        'created': true,
        'recipe': null,
        'feed': {
          'id': 'feed-id',
          'url': 'https://example.com/feed',
          'name': 'Test Feed',
          'active': true,
        },
      });

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await repository.import('https://example.com/feed', type: 'feed');

      expect(result.feed?.id, 'feed-id');
      expect(result.recipe, isNull);
    });
  });
}
