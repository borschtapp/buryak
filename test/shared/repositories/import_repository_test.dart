import 'dart:convert';

import 'package:buryak/shared/repositories/import_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../helpers/repository_harness.dart';
import '../../helpers/fake_recipe.dart';

void main() {
  final harness = setUpRepository((ref, client) => ImportRepository(ref: ref, client: client));

  group('ImportRepository', () {
    test('import returns ImportResult with recipe', () async {
      final responseBody = jsonEncode({
        'created': true,
        'recipe': fakeRecipeJson(id: 'imported-id'),
        'feed': null,
      });

      when(
        () => harness.client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await harness.repository.import('https://example.com/recipe');

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
        () => harness.client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(responseBody, 201));

      final result = await harness.repository.import('https://example.com/feed', type: 'feed');

      expect(result.feed?.id, 'feed-id');
      expect(result.recipe, isNull);
    });
  });
}
