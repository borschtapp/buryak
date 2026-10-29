import 'package:buryak/features/cooking/section_cooking_ingredients.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/fake_recipe.dart';

void main() {
  testWidgets('a zero cook time falls back to the total time', (tester) async {
    final recipe = Recipe.fromJson({...fakeRecipeJson(totalTime: 1800), 'cook_time': 0});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: CookingIngredientsPage(recipe: recipe, scale: 1, onScaleChanged: (_) {}),
          ),
        ),
      ),
    );

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.cookingCookTimeLabel(const Duration(minutes: 30).localized(l10n))), findsOneWidget);
  });
}
