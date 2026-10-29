import 'package:buryak/features/recipes/dialog_food_conversion.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/food_price.dart';
import 'package:buryak/shared/models/food_unit_conversion.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_units.dart';
import '../../helpers/sheet_opener.dart';

const _units = [piece, gram, kilogram, milliliter];

void main() {
  const onion = Food(id: 'onion', slug: 'onion', name: 'onion', defaultUnitId: 'pc');

  Future<void> open(
    WidgetTester tester, {
    required String unitId,
    List<FoodPrice> prices = const [],
    FoodUnitConversion? existing,
    String? targetUnitId,
  }) => pumpAndOpen(
    tester,
    (context) => FoodConversionBottomSheet.show(
      context,
      food: onion,
      unitId: unitId,
      unitName: unitId,
      prices: prices,
      existing: existing,
      targetUnitId: targetUnitId,
    ),
    overrides: [allUnitsProvider.overrideWith((ref) async => _units)],
  );

  AppLocalizations l10nOf(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(FoodConversionBottomSheet)));

  Future<void> openTargetPicker(WidgetTester tester) async {
    await tester.tap(find.text(l10nOf(tester).foodConversionTargetUnit));
    await tester.pumpAndSettle();
  }

  Future<void> pickTarget(WidgetTester tester, String name) async {
    await openTargetPicker(tester);
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Finder amountField(WidgetTester tester) => find.widgetWithText(TextFormField, l10nOf(tester).foodPriceAmount);
  String amount(WidgetTester tester) => tester.widget<TextFormField>(amountField(tester)).controller!.text;

  testWidgets('does not preselect the source unit as the target', (tester) async {
    // The food's default unit is the source unit itself, so fall through to the price's unit.
    await open(tester, unitId: 'pc', prices: [fakeOnionPrice('kg')]);

    expect(find.text('kilogram'), findsOneWidget);
    expect(find.text('piece'), findsNothing);
  });

  testWidgets('offers only measurable units as targets', (tester) async {
    await open(tester, unitId: 'pc');
    await openTargetPicker(tester);

    expect(find.text('gram'), findsOneWidget);
    expect(find.text('kilogram'), findsOneWidget);
    expect(find.text('milliliter'), findsOneWidget);
    expect(find.text('piece'), findsNothing);
  });

  testWidgets('hides targets that share the source unit\'s base', (tester) async {
    await open(tester, unitId: 'kg');
    await openTargetPicker(tester);

    expect(find.text('milliliter'), findsOneWidget);
    expect(find.text('gram'), findsNothing);
    expect(find.text('kilogram'), findsNothing);
  });

  group('picking another target', () {
    const existing = FoodUnitConversion(id: 'c1', foodId: 'onion', unitId: 'pc', targetUnitId: 'g', targetAmount: 50);

    testWidgets('clears the amount given for the existing target', (tester) async {
      await open(tester, unitId: 'pc', existing: existing);
      expect(amount(tester), '50');

      await pickTarget(tester, 'milliliter');

      expect(amount(tester), isEmpty);
    });

    testWidgets('restores the existing amount when its target is picked back', (tester) async {
      // A bridge preselects another target, so the existing amount starts out hidden.
      await open(tester, unitId: 'pc', existing: existing, targetUnitId: 'ml');
      expect(amount(tester), isEmpty);

      await pickTarget(tester, 'gram');

      expect(amount(tester), '50');
    });

    testWidgets('keeps an amount the user typed', (tester) async {
      await open(tester, unitId: 'pc', existing: existing);
      await tester.enterText(amountField(tester), '60');

      await pickTarget(tester, 'milliliter');

      expect(amount(tester), '60');
    });
  });
}
