import 'dart:async';

import 'package:buryak/features/shopping/notifier_shopping.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/models/shopping_item.dart';
import 'package:buryak/shared/providers/shopping.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/shopping_list_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/signed_out.dart';

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}

PaginatedList<ShoppingItem> _page(List<ShoppingItem> data) => PaginatedList(
  data: data,
  meta: Meta(total: data.length, limit: 20, offset: 0),
);

void main() {
  late MockShoppingListRepository repo;

  setUp(() => repo = MockShoppingListRepository());

  ProviderContainer containerWithList(String listId) {
    final container = ProviderContainer(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(repo),
        primaryShoppingListIdProvider.overrideWith((ref) async => listId),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('signed out: fails with SignedOutError without any request', () async {
    final container = ProviderContainer(
      overrides: [
        shoppingListRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(container.read(shoppingItemsProvider.future), throwsSignedOut);
    verifyZeroInteractions(repo);
  });

  group('addItem when the server merges into an existing row', () {
    Future<List<ShoppingItem>> addOnion(ShoppingItem existing, ShoppingItem returned) async {
      final container = containerWithList('list-1');
      when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer(
        (_) async => _page([const ShoppingItem(id: 'milk', text: 'Milk', isBought: false), existing]),
      );
      when(() => repo.createItem('list-1', (text: 'onion', amount: null, unitId: null, foodId: null))).thenAnswer((_) async => returned);
      container.listen(shoppingItemsProvider, (_, _) {});
      await container.read(shoppingItemsProvider.future);

      await container.read(shoppingItemsProvider.notifier).addItem('onion');
      return container.read(shoppingItemsProvider).requireValue;
    }

    test('an unbought item is replaced, not duplicated', () async {
      final items = await addOnion(
        const ShoppingItem(id: 'onion', text: 'Onion', amount: 1, isBought: false),
        const ShoppingItem(id: 'onion', text: 'Onion', amount: 2, isBought: false),
      );

      expect(items.map((i) => i.id), ['onion', 'milk']);
      expect(items.first.amount, 2);
    });

    test('a bought item is unchecked and moves above the bought ones', () async {
      final items = await addOnion(
        const ShoppingItem(id: 'onion', text: 'Onion', isBought: true),
        const ShoppingItem(id: 'onion', text: 'Onion', isBought: false),
      );

      expect(items.map((i) => (i.id, i.isBought)), [('onion', false), ('milk', false)]);
    });
  });

  test('addIngredients writes to the primary list and reloads the list', () async {
    final container = containerWithList('list-1');
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer((_) async => _page(const []));
    when(() => repo.createItems('list-1', any())).thenAnswer((_) async => const [ShoppingItem(id: 'i1', text: 'Milk')]);
    container.listen(shoppingItemsProvider, (_, _) {});
    await container.read(shoppingItemsProvider.future);

    await addShoppingItemsMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemWriterProvider).addIngredients(const [RecipeIngredient(id: 'i1', name: 'Milk')]),
    );
    await container.read(shoppingItemsProvider.future);

    verify(() => repo.findItems('list-1', limit: 20, offset: 0)).called(2);
  });

  test('addIngredients before the list was ever shown writes without loading it (cold start from a recipe)', () async {
    final container = containerWithList('list-1');
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer((_) async => _page(const []));
    when(() => repo.createItems('list-1', any())).thenAnswer((_) async => const [ShoppingItem(id: 'i1', text: 'Milk')]);

    await addShoppingItemsMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemWriterProvider).addIngredients(const [RecipeIngredient(id: 'i1', name: 'Milk')]),
    );

    verify(() => repo.createItems('list-1', [(text: 'Milk', amount: null, unitId: null, foodId: null)])).called(1);
    await Future<void>.delayed(Duration.zero);
    verifyNever(
      () => repo.findItems(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    );
  });

  test('addIngredients succeeds when the list is refreshed while the write is in flight', () async {
    final container = containerWithList('list-1');
    final created = Completer<List<ShoppingItem>>();
    var fetches = 0;
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer((_) async {
      fetches++;
      return _page(const []);
    });
    when(() => repo.createItems('list-1', any())).thenAnswer((_) => created.future);
    container.listen(shoppingItemsProvider, (_, _) {});
    await container.read(shoppingItemsProvider.future);

    final pending = addShoppingItemsMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemWriterProvider).addIngredients(const [RecipeIngredient(id: 'i1', name: 'Milk')]),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(shoppingItemsProvider); // e.g. pull-to-refresh
    await container.read(shoppingItemsProvider.future);
    created.complete(const [ShoppingItem(id: 'i1', text: 'Milk')]);

    await pending;
    await container.read(shoppingItemsProvider.future);
    expect(fetches, 3, reason: 'initial load, the refresh, and the reload after the write');
  });

  test('deleteShoppingItemMutation deletes the item from the list', () async {
    final container = containerWithList('list-1');
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer(
      (_) async => _page([const ShoppingItem(id: 'i1', text: 'Milk')]),
    );
    when(() => repo.deleteItem('list-1', 'i1')).thenAnswer((_) async {});
    container.listen(shoppingItemsProvider, (_, _) {});
    await container.read(shoppingItemsProvider.future);

    await deleteShoppingItemMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemsProvider.notifier).deleteItem('i1'),
    );

    expect(container.read(shoppingItemsProvider).value, isEmpty);
    verify(() => repo.deleteItem('list-1', 'i1')).called(1);
  });

  test('toggleShoppingItemMutation toggles bought state', () async {
    final container = containerWithList('list-1');
    const item = ShoppingItem(id: 'i1', text: 'Milk', isBought: false);
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer(
      (_) async => _page([item]),
    );
    when(() => repo.updateItem('list-1', 'i1', isBought: true)).thenAnswer((_) async => item.copyWith(isBought: true));
    container.listen(shoppingItemsProvider, (_, _) {});
    await container.read(shoppingItemsProvider.future);

    await toggleShoppingItemMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemsProvider.notifier).toggleItem(item),
    );

    expect(container.read(shoppingItemsProvider).value?.first.isBought, isTrue);
    verify(() => repo.updateItem('list-1', 'i1', isBought: true)).called(1);
  });
}
