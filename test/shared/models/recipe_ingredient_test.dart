import 'package:flutter_test/flutter_test.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/unit.dart';

void main() {
  group('RecipeIngredient', () {
    test('displayName returns name if present', () {
      final ingredient = RecipeIngredient(id: '1', name: 'Salt');
      expect(ingredient.displayName, 'Salt');
    });

    test('displayName returns food name if name is null', () {
      final ingredient = RecipeIngredient(
        id: '1',
        food: Food(id: '1', name: 'Pepper', slug: 'pcs'),
      );
      expect(ingredient.displayName, 'Pepper');
    });

    test('displayName returns rawText if name and food name are null', () {
      final ingredient = RecipeIngredient(id: '1', rawText: '1 pinch of spice');
      expect(ingredient.displayName, '1 pinch of spice');
    });

    test('displayName returns description if other fields are null', () {
      final ingredient = RecipeIngredient(id: '1', description: 'Some ingredient');
      expect(ingredient.displayName, 'Some ingredient');
    });

    test('displayName returns fallback if all fields are null', () {
      final ingredient = RecipeIngredient(id: '1');
      expect(ingredient.displayName, 'Unknown ingredient');
    });

    test('displayAmount joins amount and unit', () {
      final ingredient = RecipeIngredient(
        id: '1',
        amount: 500,
        unit: Unit(id: 'g', name: 'g', slug: 'g'),
      );
      expect(ingredient.displayAmount, '500.0 g');
    });

    test('displayAmount returns amount only if unit is missing', () {
      final ingredient = RecipeIngredient(id: '1', amount: 3);
      expect(ingredient.displayAmount, '3.0');
    });

    test('displayAmount returns unit name only if amount is missing', () {
      final ingredient = RecipeIngredient(
        id: '1',
        unit: Unit(id: 'pcs', name: 'pieces', slug: 'pcs'),
      );
      expect(ingredient.displayAmount, 'pieces');
    });

    test('displayAmount returns empty string if both missing', () {
      final ingredient = RecipeIngredient(id: '1');
      expect(ingredient.displayAmount, '');
    });
  });
}
