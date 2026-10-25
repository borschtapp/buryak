import 'package:buryak/features/recipes/dialog_food_conversion.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/food_price.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/fake_units.dart';

const _units = [piece, gram, kilogram, milliliter];

void main() {
  const onion = Food(id: 'onion', slug: 'onion', name: 'onion', defaultUnitId: 'pc');

  Future<void> open(WidgetTester tester, {required String unitId, List<FoodPrice> prices = const []}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [allUnitsProvider.overrideWith((ref) async => _units)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: FoodConversionBottomSheet(food: onion, unitId: unitId, unitName: unitId, prices: prices),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTargetPicker(WidgetTester tester) async {
    final l10n = AppLocalizations.of(tester.element(find.byType(FoodConversionBottomSheet)));
    await tester.tap(find.text(l10n.foodConversionTargetUnit));
    await tester.pumpAndSettle();
  }

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
}
