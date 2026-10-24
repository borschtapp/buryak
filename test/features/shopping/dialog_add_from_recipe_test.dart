import 'package:buryak/features/shopping/dialog_add_from_recipe.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/fake_recipe.dart';

void main() {
  testWidgets('fully expanded, the sheet stops one toolbar below the status bar', (tester) async {
    const statusBar = 47.0;
    tester.view.padding = FakeViewPadding(top: statusBar * tester.view.devicePixelRatio);
    addTearDown(tester.view.reset);
    // Enough ingredients that the list fills the sheet, so the sheet's top is the content's top.
    final recipe = Recipe.fromJson({
      ...fakeRecipeJson(),
      'ingredients': [
        for (var i = 0; i < 40; i++) {'id': 'i$i', 'name': 'ingredient $i'},
      ],
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => ShoppingBottomSheet.show(context, recipe),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ShoppingBottomSheet), const Offset(0, -2000), 3000);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(ShoppingBottomSheet)).dy, statusBar + kToolbarHeight);
  });
}
