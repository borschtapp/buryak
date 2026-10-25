import 'package:buryak/features/shopping/dialog_add_from_recipe.dart';
import 'package:buryak/l10n/app_localizations.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/models/shopping_item.dart';
import 'package:buryak/shared/providers/shopping.dart';
import 'package:buryak/shared/repositories/shopping_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}

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

  /// Opens the sheet for [recipe] and taps "Add to list" with the default selection.
  Future<AppLocalizations> addAll(WidgetTester tester, MockShoppingListRepository repo, Recipe recipe) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => ShoppingBottomSheet.show(context, recipe),
              child: const Text('open'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingListRepositoryProvider.overrideWithValue(repo),
          primaryShoppingListIdProvider.overrideWith((ref) async => 'list-1'),
        ],
        child: MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, routerConfig: router),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(ShoppingBottomSheet)));
    await tester.tap(find.text(l10n.shoppingAddToList));
    await tester.pumpAndSettle();
    return l10n;
  }

  testWidgets('reports every ingredient added when the server merges duplicates into one row', (tester) async {
    final repo = MockShoppingListRepository();
    when(() => repo.createItems('list-1', any())).thenAnswer(
      (_) async => const [ShoppingItem(id: 'onion', text: 'onion', amount: 3)],
    );
    final recipe = Recipe.fromJson({
      ...fakeRecipeJson(),
      'ingredients': [
        {'id': 'i1', 'name': 'onion', 'amount': 1},
        {'id': 'i2', 'name': 'onion', 'amount': 2},
      ],
    });

    final l10n = await addAll(tester, repo, recipe);

    expect(find.byType(ShoppingBottomSheet), findsNothing);
    expect(find.text(l10n.shoppingAllIngredientsAdded), findsOneWidget);
  });

  testWidgets('adds only the listed ingredients, linked to their food', (tester) async {
    final repo = MockShoppingListRepository();
    when(() => repo.createItems('list-1', any())).thenAnswer((_) async => const []);
    final recipe = Recipe.fromJson({
      ...fakeRecipeJson(),
      'ingredients': [
        {
          'id': 'i1',
          'name': 'red onions',
          'amount': 2,
          'unit_id': 'pc',
          'food_id': 'onion',
          'food': {'id': 'onion', 'slug': 'onion', 'name': 'onion'},
        },
        {'id': 'i2', 'name': 'water'},
        {
          'id': 'i3',
          'name': 'salt',
          'food_id': 'salt',
          'food': {'id': 'salt', 'slug': 'salt', 'name': 'salt', 'pantry': true},
        },
      ],
    });

    await addAll(tester, repo, recipe);

    final sent = verify(() => repo.createItems('list-1', captureAny())).captured.single;
    expect(sent, [
      {'text': 'red onions', 'amount': 2.0, 'unit_id': 'pc', 'food_id': 'onion'},
      {'text': 'water'},
    ]);
  });
}
