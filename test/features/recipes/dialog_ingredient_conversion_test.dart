import 'package:buryak/features/recipes/dialog_food_conversion.dart';
import 'package:buryak/features/recipes/dialog_food_price.dart';
import 'package:buryak/features/recipes/dialog_ingredient_conversion.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/food_unit_conversion.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/fake_units.dart';

void main() {
  group('IngredientConversionSheet', () {
    const onion = Food(id: 'onion', slug: 'onion', name: 'onion');

    Future<AppLocalizations> open(
      WidgetTester tester,
      RecipeIngredient ingredient, {
      required String priceUnitId,
      List<FoodUnitConversion> conversions = const [],
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWithValue(null),
            allUnitsProvider.overrideWith((ref) async => const [piece, can, gram, kilogram, milliliter, cup]),
            foodPricesProvider(onion.id).overrideWith(
              (ref) async => PaginatedList(data: [fakeOnionPrice(priceUnitId)], meta: const Meta(total: 1, limit: 20, offset: 0)),
            ),
            foodConversionsProvider(onion.id).overrideWith((ref) async => conversions),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(body: IngredientConversionSheet(ingredient: ingredient)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return AppLocalizations.of(tester.element(find.byType(IngredientConversionSheet)));
    }

    testWidgets('a unitless ingredient priced per kg gets a piece → kg conversion', (tester) async {
      final l10n = await open(
        tester,
        const RecipeIngredient(id: 'i1', amount: 2, foodId: 'onion', food: onion),
        priceUnitId: 'kg',
      );

      expect(find.byType(FoodConversionBottomSheet), findsOneWidget);
      expect(find.text(l10n.foodConversionFormHint('piece', 'onion')), findsOneWidget);
      expect(find.text('kilogram'), findsOneWidget);
    });

    testWidgets('an ingredient in grams priced per piece gets a piece → g conversion', (tester) async {
      final l10n = await open(
        tester,
        const RecipeIngredient(id: 'i1', amount: 300, unitId: 'g', foodId: 'onion', food: onion),
        priceUnitId: 'pc',
      );

      expect(find.text(l10n.foodConversionFormHint('piece', 'onion')), findsOneWidget);
      expect(find.text('gram'), findsOneWidget);
    });

    testWidgets('an existing conversion is retargeted, without carrying over its amount', (tester) async {
      await open(
        tester,
        const RecipeIngredient(id: 'i1', amount: 2, foodId: 'onion', food: onion),
        priceUnitId: 'kg',
        conversions: const [FoodUnitConversion(id: 'c1', foodId: 'onion', unitId: 'pc', targetUnitId: 'ml', targetAmount: 150)],
      );

      expect(find.text('kilogram'), findsOneWidget);
      expect(find.text('150'), findsNothing);
    });

    testWidgets('falls back to the price form when one conversion cannot bridge the units', (tester) async {
      await open(
        tester,
        const RecipeIngredient(id: 'i1', amount: 2, foodId: 'onion', food: onion),
        priceUnitId: 'can',
      );

      expect(find.byType(FoodPriceBottomSheet), findsOneWidget);
      expect(find.byType(FoodConversionBottomSheet), findsNothing);
    });
  });
}
