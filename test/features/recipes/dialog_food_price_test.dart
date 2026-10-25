import 'package:buryak/features/recipes/dialog_food_price.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/food_price.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/fake_units.dart';

const _units = [piece, gram, kilogram];

void main() {
  const onion = Food(id: 'onion', slug: 'onion', name: 'onion', defaultUnitId: 'kg');

  Future<void> open(WidgetTester tester, RecipeIngredient ingredient) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionProvider.overrideWithValue(null),
          allUnitsProvider.overrideWith((ref) async => _units),
          foodPricesProvider(onion.id).overrideWith(
            (ref) async => PaginatedList<FoodPrice>(data: const [], meta: const Meta(total: 0, limit: 20, offset: 0)),
          ),
          foodConversionsProvider(onion.id).overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: FoodPriceBottomSheet(food: onion, ingredient: ingredient),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a unitless ingredient is priced per piece, as the server counts it', (tester) async {
    await open(tester, const RecipeIngredient(id: 'i1', name: 'onions', amount: 2, foodId: 'onion', food: onion));

    expect(find.text('piece'), findsOneWidget);
    expect(find.text('kilogram'), findsNothing);
  });

  testWidgets('an ingredient with a unit is priced in that unit', (tester) async {
    await open(tester, const RecipeIngredient(id: 'i1', name: 'onions', amount: 300, unitId: 'g', foodId: 'onion', food: onion));

    expect(find.text('gram'), findsOneWidget);
  });
}
