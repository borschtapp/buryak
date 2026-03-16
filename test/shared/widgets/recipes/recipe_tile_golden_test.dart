import 'package:buryak/shared/widgets/recipes/view_recipe_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../helpers/fake_recipe.dart';

void main() {
  group('RecipeTile Golden Tests', () {
    testWidgets('RecipeTile renders correctly', (tester) async {
      final recipe = fakeRecipe(
        id: 'golden-recipe',
        name: 'Delicious Golden Borscht',
        totalTime: 45,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 350,
                  height: 450,
                  child: RecipeTile(recipe: recipe),
                ),
              ),
            ),
          ),
        ),
      );

      // We need to wait for any images or animations
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RecipeTile),
        matchesGoldenFile('goldens/recipe_tile.png'),
      );
    });
  });
}
