import 'dart:convert';
import 'package:buryak/shared/repositories/recipe_repository.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/models/user.dart';
import 'package:buryak/shared/models/recipe.dart';
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
  late RecipeRepository repository;
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
    repository = RecipeRepository(
      ref: container.read(Provider<Ref>((ref) => ref)),
      client: mockClient,
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('RecipeRepository', () {
    test('findAll returns a list of recipes', () async {
      final recipesJson = [fakeRecipeJson(), fakeRecipeJson()];
      final responseBody = jsonEncode({
        'data': recipesJson,
        'meta': {'page': 1, 'total': 2, 'limit': 20, 'offset': 0},
      });

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repository.findAll();
      expect(result.data[0].name, 'Test Recipe');
      expect(result.data[0].id, '1');
    });

    test('findOne returns a single recipe', () async {
      final recipeJson = fakeRecipeJson(id: '123');
      final responseBody = jsonEncode({'data': recipeJson});

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repository.findOne('123');

      expect(result.id, '123');
      expect(result.name, 'Test Recipe');
    });

    test('create returns the created recipe', () async {
      final recipeJson = fakeRecipeJson(id: 'new-id');
      final responseBody = jsonEncode({'data': recipeJson});

      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await repository.create(Recipe.fromJson(fakeRecipeJson()));

      expect(result.id, 'new-id');
    });

    test('import returns the imported recipe', () async {
      final recipeJson = fakeRecipeJson(id: 'imported-id');
      final responseBody = jsonEncode({'data': recipeJson});

      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await repository.import('https://example.com/recipe');

      expect(result.id, 'imported-id');
    });

    test('throws exception on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() => repository.findAll(), throwsA(isA<Exception>()));
    });
  });
}
