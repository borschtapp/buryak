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
import 'package:intl/intl.dart';

import '../../helpers/fake_units.dart';

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

  Future<void> pumpCost(
    WidgetTester tester,
    List<RecipeIngredient> ingredients,
    List<RecipeIngredientCost> items, {
    void Function(RecipeIngredient)? onAddPrice,
    void Function(RecipeIngredient)? onIngredientTap,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWithValue(null),
          recipeCostEstimateProvider('r1').overrideWith((ref) async => RecipeCostEstimate(items: items, total: 1.2)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: RecipeCost(recipeId: 'r1', ingredients: ingredients, onAddPrice: onAddPrice, onIngredientTap: onIngredientTap),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  AppLocalizations l10nOf(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(RecipeCost)));

  String money(WidgetTester tester, double value) => NumberFormat.simpleCurrency(locale: l10nOf(tester).localeName).format(value);

  testWidgets('offers a conversion for a unit mismatch and a price for a missing one', (tester) async {
    final added = <String>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWithValue(null),
          recipeCostEstimateProvider('r1').overrideWith(
            (ref) async => RecipeCostEstimate(
              items: [
                RecipeIngredientCost(ingredientId: 'onion', status: IngredientCostStatus.incompatibleUnit, foodPrice: fakeOnionPrice('kg')),
                const RecipeIngredientCost(ingredientId: 'leek', status: IngredientCostStatus.missingPrice),
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
              onAddConversion: (i, price) => added.add('conversion:${i.id}:${price.unitId}'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.recipeCostAddConversion));
    await tester.tap(find.text(l10n.recipeCostAddPrice));

    expect(added, ['conversion:onion:kg', 'price:leek']);
  });

  testWidgets('shows the price a converted cost comes from', (tester) async {
    await pumpCost(
      tester,
      const [onion],
      [
        RecipeIngredientCost(
          ingredientId: 'onion',
          cost: 1.2,
          status: IngredientCostStatus.calculated,
          foodPrice: fakeOnionPrice('kg').copyWith(unit: kilogram),
        ),
      ],
    );
    final l10n = l10nOf(tester);

    expect(find.text(l10n.recipeCostPriceBasis(money(tester, 2), 'kilogram')), findsOneWidget);
  });

  testWidgets('shows the recorded price amount, not the ingredient amount, for the same unit', (tester) async {
    const flour = RecipeIngredient(
      id: 'flour',
      name: 'flour',
      amount: 200,
      unitId: 'g',
      unit: gram,
      foodId: 'flour',
      food: Food(id: 'flour', slug: 'flour', name: 'flour'),
    );
    final price = fakeOnionPrice('g').copyWith(foodId: 'flour', amount: 500, unit: gram);
    await pumpCost(
      tester,
      const [flour],
      [
        RecipeIngredientCost(ingredientId: 'flour', cost: 0.8, status: IngredientCostStatus.calculated, foodPrice: price),
      ],
    );
    final l10n = l10nOf(tester);

    expect(find.text(l10n.recipeCostPriceBasisAmount(money(tester, 2), '500', 'gram')), findsOneWidget);
  });

  testWidgets('tapping an ingredient opens its price, or the ingredient when it has no food', (tester) async {
    const salt = RecipeIngredient(id: 'salt', name: 'salt', amount: 1);
    final tapped = <String>[];
    await pumpCost(
      tester,
      const [onion, salt],
      [
        RecipeIngredientCost(ingredientId: 'onion', cost: 1.2, status: IngredientCostStatus.calculated, foodPrice: fakeOnionPrice('kg')),
        const RecipeIngredientCost(ingredientId: 'salt', status: IngredientCostStatus.missingPrice),
      ],
      onAddPrice: (i) => tapped.add('price:${i.id}'),
      onIngredientTap: (i) => tapped.add('edit:${i.id}'),
    );

    await tester.tap(find.text('onions'));
    await tester.tap(find.text('salt'));

    expect(tapped, ['price:onion', 'edit:salt']);
  });

  test('progress counts are pluralized', () {
    expect(lookupAppLocalizations(const Locale('en')).recipeCostProgress(1, 1), '1 of 1 ingredient priced');
    expect(lookupAppLocalizations(const Locale('en')).recipeCostProgress(1, 2), '1 of 2 ingredients priced');
    expect(lookupAppLocalizations(const Locale('de')).recipeCostProgress(1, 1), '1 von 1 Zutat mit Preis');
    expect(lookupAppLocalizations(const Locale('uk')).recipeCostProgress(1, 1), '1 з 1 інгредієнта оцінено');
    expect(lookupAppLocalizations(const Locale('uk')).recipeCostProgress(2, 5), '2 з 5 інгредієнтів оцінено');
  });

  testWidgets('displays section headers and progress indicator', (tester) async {
    await pumpCost(
      tester,
      const [onion, leek],
      [
        RecipeIngredientCost(ingredientId: 'onion', cost: 1.2, status: IngredientCostStatus.calculated, foodPrice: fakeOnionPrice('kg')),
        const RecipeIngredientCost(ingredientId: 'leek', status: IngredientCostStatus.missingPrice),
      ],
      onAddPrice: (_) {},
    );
    final l10n = l10nOf(tester);

    expect(find.text(l10n.recipeCostSectionMissing), findsOneWidget);
    expect(find.text(l10n.recipeCostSectionPriced), findsOneWidget);
    expect(find.text(l10n.recipeCostProgress(1, 2)), findsOneWidget);
  });
}
