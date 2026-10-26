import 'package:buryak/shared/models/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Recipe dates', () {
    test('displayDate returns published when available', () {
      final published = DateTime.utc(2025, 5, 10);
      final created = DateTime.utc(2025, 4, 1);
      final recipe = Recipe(id: '1', name: 'Test', published: published, created: created);

      expect(recipe.displayDate, published);
    });

    test('displayDate falls back to created when published is not available', () {
      final created = DateTime.utc(2025, 4, 1);
      final recipe = Recipe(id: '1', name: 'Test', created: created);

      expect(recipe.displayDate, created);
    });

    test('displayDate returns null when neither published nor created is available', () {
      const recipe = Recipe(id: '1', name: 'Test');

      expect(recipe.displayDate, isNull);
    });

    test('fromJson reads created from "created"', () {
      final recipe = Recipe.fromJson({
        'id': '1',
        'name': 'Test',
        'created': '2025-03-15T12:00:00Z',
      });

      expect(recipe.created, DateTime.utc(2025, 3, 15, 12));
      expect(recipe.displayDate, DateTime.utc(2025, 3, 15, 12));
    });

    test('fromJson reads updated from "updated"', () {
      final recipe = Recipe.fromJson({
        'id': '1',
        'name': 'Test',
        'updated': '2025-07-21T15:30:00Z',
      });

      expect(recipe.updated, DateTime.utc(2025, 7, 21, 15, 30));
    });

    test('fromJson reads published from "published"', () {
      final recipe = Recipe.fromJson({
        'id': '1',
        'name': 'Test',
        'published': '2025-06-20T10:00:00Z',
      });

      expect(recipe.published, DateTime.utc(2025, 6, 20, 10));
      expect(recipe.displayDate, DateTime.utc(2025, 6, 20, 10));
    });
  });
}
