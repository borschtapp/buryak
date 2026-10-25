import 'package:buryak/features/recipes/dialog_edit_food.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/food_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/sheet_opener.dart';

class MockFoodRepository extends Mock implements FoodRepository {}

void main() {
  late MockFoodRepository foods;

  setUp(() {
    foods = MockFoodRepository();
    when(
      () => foods.update(
        any(),
        name: any(named: 'name'),
        description: any(named: 'description'),
        defaultUnitId: any(named: 'defaultUnitId'),
        clearDefaultUnit: any(named: 'clearDefaultUnit'),
        pantry: any(named: 'pantry'),
      ),
    ).thenAnswer((_) async => const Food(id: 'f1', slug: 'onion', name: 'onion'));
  });

  /// Opens the sheet for [food]; returns the strings to find its fields by.
  Future<AppLocalizations> open(WidgetTester tester, Food food) async {
    await pumpAndOpen(
      tester,
      (context) => EditFoodBottomSheet.show(context, food: food),
      overrides: [
        sessionProvider.overrideWithValue(null),
        foodRepositoryProvider.overrideWithValue(foods),
        allUnitsProvider.overrideWith((ref) async => const []),
      ],
    );
    return AppLocalizations.of(tester.element(find.byType(EditFoodBottomSheet)));
  }

  Future<void> save(WidgetTester tester, AppLocalizations l10n) async {
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();
  }

  testWidgets('saves a new description', (tester) async {
    final l10n = await open(tester, const Food(id: 'f1', slug: 'onion', name: 'onion'));

    await tester.enterText(find.widgetWithText(TextFormField, l10n.editFoodDescription), '  Yellow, for frying ');
    await save(tester, l10n);

    verify(() => foods.update('f1', description: 'Yellow, for frying')).called(1);
  });

  testWidgets('an emptied description is cleared', (tester) async {
    final l10n = await open(tester, const Food(id: 'f1', slug: 'onion', name: 'onion', description: 'Yellow'));

    await tester.enterText(find.widgetWithText(TextFormField, l10n.editFoodDescription), ' ');
    await save(tester, l10n);

    verify(() => foods.update('f1', description: '')).called(1);
  });

  testWidgets('an untouched description is not sent', (tester) async {
    final l10n = await open(tester, const Food(id: 'f1', slug: 'onion', name: 'onion', description: 'Yellow'));

    await tester.tap(find.text(l10n.editFoodPantry));
    await save(tester, l10n);

    verify(() => foods.update('f1', pantry: true)).called(1);
  });
}
