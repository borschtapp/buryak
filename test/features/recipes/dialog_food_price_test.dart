import 'dart:async';

import 'package:buryak/features/recipes/dialog_food_price.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/food_price.dart';
import 'package:buryak/shared/models/food_unit_conversion.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/models/unit.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show Override;

import '../../helpers/fake_units.dart';
import '../../helpers/sheet_opener.dart';

const _units = [piece, can, gram, kilogram, milliliter];

void main() {
  const onion = Food(id: 'onion', slug: 'onion', name: 'onion', defaultUnitId: 'kg');
  // Unitless, so the server counts it in pieces.
  const onions = RecipeIngredient(id: 'i1', name: 'onions', amount: 2, foodId: 'onion', food: onion);

  List<Override> overrides({
    List<FoodPrice> prices = const [],
    List<FoodUnitConversion> conversions = const [],
    Future<List<Unit>>? units,
  }) => [
    sessionProvider.overrideWithValue(null),
    allUnitsProvider.overrideWith((ref) => units ?? Future.value(_units)),
    // Reads [prices] on every load, so a test can change them in place between loads.
    foodPricesProvider(onion.id).overrideWith(
      (ref) async => PaginatedList<FoodPrice>(
        data: [...prices],
        meta: Meta(total: prices.length, limit: 20, offset: 0),
      ),
    ),
    foodConversionsProvider(onion.id).overrideWith((ref) async => conversions),
  ];

  Future<void> open(
    WidgetTester tester,
    RecipeIngredient? ingredient, {
    Food food = onion,
    List<FoodPrice> prices = const [],
    List<FoodUnitConversion> conversions = const [],
    ProviderContainer? container,
  }) => pumpAndOpen(
    tester,
    (context) => FoodPriceBottomSheet.show(context, food: food, ingredient: ingredient),
    container: container,
    overrides: overrides(prices: prices, conversions: conversions),
  );

  AppLocalizations l10nOf(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(FoodPriceBottomSheet)));

  Future<void> pickUnit(WidgetTester tester, String from, String to) async {
    await tester.tap(find.text(from));
    await tester.pumpAndSettle();
    await tester.tap(find.text(to).last);
    await tester.pumpAndSettle();
  }

  testWidgets('a unitless ingredient is priced per piece, as the server counts it', (tester) async {
    await open(tester, onions);

    expect(find.text('piece'), findsOneWidget);
    expect(find.text('kilogram'), findsNothing);
  });

  testWidgets('an ingredient with a unit is priced in that unit', (tester) async {
    await open(tester, const RecipeIngredient(id: 'i1', name: 'onions', amount: 300, unitId: 'g', foodId: 'onion', food: onion));

    expect(find.text('gram'), findsOneWidget);
  });

  testWidgets('does not prefill price when the latest price has a different unit', (tester) async {
    await open(tester, onions, prices: [fakeOnionPrice('kg')]);

    // The unitless ingredient is priced per piece, so the kg price (2) should not be prefilled.
    expect(find.text('2'), findsNothing);
  });

  testWidgets('prefills price and amount when the latest price matches the selected unit', (tester) async {
    await open(tester, onions, prices: [fakeOnionPrice('pc')]);

    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('does not prefill a price in another unit while the units are still loading', (tester) async {
    final units = Completer<List<Unit>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(prices: [fakeOnionPrice('kg')], units: units.future),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: FoodPriceBottomSheet(food: onion, ingredient: onions),
          ),
        ),
      ),
    );
    // Prices load first; until units do, the piece unit is unknown and the food's kg default is selected.
    await tester.pump();
    units.complete(_units);
    await tester.pumpAndSettle();

    expect(find.text('piece'), findsOneWidget);
    expect(find.text('2'), findsNothing);
  });

  testWidgets('shows conversion alert when selected unit differs from ingredient unit without conversion', (tester) async {
    await open(tester, onions);
    final l10n = l10nOf(tester);

    // Initially selected unit is piece, so the standard button is shown.
    expect(find.text(l10n.foodConversionSetButton('piece')), findsOneWidget);

    await pickUnit(tester, 'piece', 'kilogram');

    // Now piece and kilogram require a bridge conversion, so the warning and bridge button are shown.
    expect(find.text(l10n.foodPriceConversionNeeded('piece', 'kilogram')), findsOneWidget);
    expect(find.text(l10n.foodConversionSetButton('piece')), findsOneWidget);
  });

  testWidgets('a conversion that cannot reach the price unit still asks for one', (tester) async {
    await open(
      tester,
      onions,
      conversions: const [FoodUnitConversion(id: 'c1', foodId: 'onion', unitId: 'pc', targetUnitId: 'ml', targetAmount: 200)],
    );
    await pickUnit(tester, 'piece', 'kilogram');

    // piece → ml doesn't let pieces be priced per kg.
    expect(find.text(l10nOf(tester).foodPriceConversionNeeded('piece', 'kilogram')), findsOneWidget);
  });

  testWidgets('editing a conversion that already links the units keeps its target and amount', (tester) async {
    await open(
      tester,
      onions,
      conversions: const [FoodUnitConversion(id: 'c1', foodId: 'onion', unitId: 'pc', targetUnitId: 'g', targetAmount: 50)],
    );
    await pickUnit(tester, 'piece', 'kilogram');
    final l10n = l10nOf(tester);

    // piece → g already prices pieces per kg, as grams scale to kilograms.
    expect(find.text(l10n.foodPriceConversionNeeded('piece', 'kilogram')), findsNothing);
    expect(find.text(l10n.foodConversionSummary('piece', '50', 'gram')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, '50'), findsOneWidget);
    expect(find.text('gram'), findsOneWidget);
  });

  testWidgets('prefills the latest price recorded in the selected unit, even if not the newest', (tester) async {
    await open(
      tester,
      onions,
      prices: [
        fakeOnionPrice('kg'),
        fakeOnionPrice('pc').copyWith(id: 'p2', price: 0.3),
      ],
    );

    expect(find.text('0.3'), findsOneWidget);
  });

  testWidgets('deleting the newest price does not switch the unit taken from it', (tester) async {
    const plain = Food(id: 'onion', slug: 'onion', name: 'onion');
    final prices = [fakeOnionPrice('kg'), fakeOnionPrice('pc').copyWith(id: 'p2')];
    final container = ProviderContainer(overrides: overrides(prices: prices));
    addTearDown(container.dispose);
    await open(tester, null, food: plain, container: container);
    expect(find.text('kilogram'), findsOneWidget);

    prices.removeAt(0);
    container.invalidate(foodPricesProvider(plain.id));
    await tester.pumpAndSettle();

    expect(find.text('kilogram'), findsOneWidget);
  });

  testWidgets('says when no conversion can link the recipe unit with the price unit', (tester) async {
    await open(tester, const RecipeIngredient(id: 'i1', name: 'tomatoes', amount: 1, unitId: 'can', foodId: 'onion', food: onion));
    await pickUnit(tester, 'can', 'piece');

    expect(find.text(l10nOf(tester).foodPriceUnitsUnlinkable('can', 'piece')), findsOneWidget);
    // A conversion for the price unit can't price the recipe's amount, so none is offered.
    expect(find.text(l10nOf(tester).foodConversionSetButton('piece')), findsNothing);
  });

  testWidgets('hides the price unit\'s conversion when it cannot link the recipe unit', (tester) async {
    await open(
      tester,
      const RecipeIngredient(id: 'i1', name: 'tomatoes', amount: 1, unitId: 'can', foodId: 'onion', food: onion),
      conversions: const [
        FoodUnitConversion(id: 'c1', foodId: 'onion', unitId: 'pc', targetUnitId: 'g', targetAmount: 50, targetUnit: gram),
      ],
    );
    await pickUnit(tester, 'can', 'piece');
    final l10n = l10nOf(tester);

    expect(find.text(l10n.foodPriceUnitsUnlinkable('can', 'piece')), findsOneWidget);
    expect(find.text(l10n.foodConversionSummary('piece', '50', 'gram')), findsNothing);
    expect(find.byTooltip(l10n.delete), findsNothing);
  });

  testWidgets('a conversion that a bridge retargets says it will be replaced', (tester) async {
    await open(
      tester,
      onions,
      conversions: const [
        FoodUnitConversion(id: 'c1', foodId: 'onion', unitId: 'pc', targetUnitId: 'g', targetAmount: 50, targetUnit: gram),
      ],
    );
    await pickUnit(tester, 'piece', 'milliliter');
    final l10n = l10nOf(tester);

    await tester.tap(find.text(l10n.foodConversionSetButton('piece')));
    await tester.pumpAndSettle();

    expect(find.text(l10n.foodConversionReplaces(l10n.foodConversionSummary('piece', '50', 'gram'))), findsOneWidget);
  });

  group('picking another unit', () {
    Finder priceField(WidgetTester tester) => find.widgetWithText(TextFormField, l10nOf(tester).foodPricePrice);
    Finder amountField(WidgetTester tester) => find.widgetWithText(TextFormField, l10nOf(tester).foodPriceAmount);
    String price(WidgetTester tester) => tester.widget<TextFormField>(priceField(tester)).controller!.text;
    String amount(WidgetTester tester) => tester.widget<TextFormField>(amountField(tester)).controller!.text;

    testWidgets('prefills the latest price recorded in that unit', (tester) async {
      await open(
        tester,
        onions,
        prices: [
          fakeOnionPrice('pc'),
          fakeOnionPrice('kg').copyWith(id: 'p2', price: 3, amount: 2),
        ],
      );
      await pickUnit(tester, 'piece', 'kilogram');

      expect(price(tester), '3');
      expect(amount(tester), '2');
    });

    testWidgets('clears a prefilled price when that unit has none', (tester) async {
      await open(tester, onions, prices: [fakeOnionPrice('pc')]);
      await pickUnit(tester, 'piece', 'kilogram');

      expect(price(tester), isEmpty);
      expect(amount(tester), '100');
    });

    testWidgets('keeps a price the user typed', (tester) async {
      await open(
        tester,
        onions,
        prices: [
          fakeOnionPrice('pc'),
          fakeOnionPrice('kg').copyWith(id: 'p2', price: 3),
        ],
      );
      await tester.enterText(priceField(tester), '5');
      await pickUnit(tester, 'piece', 'kilogram');

      expect(price(tester), '5');
      expect(amount(tester), '1');
    });
  });
}
