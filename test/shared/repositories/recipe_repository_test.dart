import 'dart:convert';

import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/repositories/recipe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';
import '../../helpers/repository_harness.dart';

void main() {
  final harness = setUpRepository((ref, client) => RecipeRepository(ref: ref, client: client));

  group('RecipeRepository', () {
    test('findAll returns a list of recipes', () async {
      final recipesJson = [fakeRecipeJson(), fakeRecipeJson()];
      final responseBody = jsonEncode({
        'data': recipesJson,
        'meta': {'page': 1, 'total': 2, 'limit': 20, 'offset': 0},
      });

      when(
        () => harness.client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await harness.repository.findAll();
      expect(result.data[0].name, 'Test Recipe');
      expect(result.data[0].id, '1');
    });

    test('findOne returns a single recipe', () async {
      final recipeJson = fakeRecipeJson(id: '123');
      final responseBody = jsonEncode(recipeJson);

      when(
        () => harness.client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await harness.repository.findOne('123');

      expect(result.id, '123');
      expect(result.name, 'Test Recipe');
    });

    test('create returns the created recipe', () async {
      final recipeJson = fakeRecipeJson(id: 'new-id');
      final responseBody = jsonEncode(recipeJson);

      when(
        () => harness.client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await harness.repository.create(Recipe.fromJson(fakeRecipeJson()));

      expect(result.id, 'new-id');
    });

    test('refresh posts to the recipe and returns the refreshed recipe', () async {
      when(
        () => harness.client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(fakeRecipeJson(id: '123', name: 'Refreshed')), 200));

      final result = await harness.repository.refresh('123');

      expect(result.name, 'Refreshed');
      final uri =
          verify(
                () => harness.client.post(
                  captureAny(),
                  headers: any(named: 'headers'),
                  body: any(named: 'body'),
                ),
              ).captured.single
              as Uri;
      expect(uri.path, endsWith('/api/v1/recipes/123/refresh'));
    });

    test('throws exception on error', () async {
      when(
        () => harness.client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('Error', 500));

      expect(() => harness.repository.findAll(), throwsA(isA<Exception>()));
    });
  });
}
