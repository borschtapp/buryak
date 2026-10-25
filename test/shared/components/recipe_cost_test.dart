import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/components/recipes/recipe_cost.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/recipe_cost_estimate.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  const onion = RecipeIngredient(
    id: 'onion',
    name: 'onions',
    amount: 2,
    foodId: 'onion',
    food: Food(id: 'onion', slug: 'onion', name: 'onion'),
  );
  const leek = RecipeIngredient(
    id: 'leek',
    name: 'leek',
    amount: 1,
    foodId: 'leek',
    food: Food(id: 'leek', slug: 'leek', name: 'leek'),
  );

  testWidgets('offers a conversion for a unit mismatch and a price for a missing one', (tester) async {
    final added = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWithValue(null),
          recipeCostEstimateProvider('r1').overrideWith(
            (ref) async => const RecipeCostEstimate(
              items: [
                RecipeIngredientCost(ingredientId: 'onion', status: IngredientCostStatus.incompatibleUnit),
                RecipeIngredientCost(ingredientId: 'leek', status: IngredientCostStatus.missingPrice),
              ],
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: RecipeCost(
              recipeId: 'r1',
              ingredients: const [onion, leek],
              onAddPrice: (i) => added.add('price:${i.id}'),
              onAddConversion: (i) => added.add('conversion:${i.id}'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(RecipeCost)));

    await tester.tap(find.text(l10n.recipeCostAddConversion));
    await tester.tap(find.text(l10n.recipeCostAddPrice));

    expect(added, ['conversion:onion', 'price:leek']);
  });
}
