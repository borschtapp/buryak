import 'dart:async';

import 'package:buryak/features/shopping/notifier_shopping.dart';
import 'package:buryak/shared/models/paginated_list.dart';
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

  test('addItems writes to the primary list, returns the count, and reloads the list', () async {
    final container = containerWithList('list-1');
    final items = [
      {'text': 'Milk'},
    ];
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer((_) async => _page(const []));
    when(() => repo.createItems('list-1', items)).thenAnswer((_) async => const [ShoppingItem(id: 'i1', text: 'Milk')]);
    container.listen(shoppingItemsProvider, (_, _) {});
    await container.read(shoppingItemsProvider.future);

    final count = await addShoppingItemsMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemWriterProvider).addItems(items),
    );
    await container.read(shoppingItemsProvider.future);

    expect(count, 1);
    verify(() => repo.findItems('list-1', limit: 20, offset: 0)).called(2);
  });

  test('addItems before the list was ever shown writes without loading it (cold start from a recipe)', () async {
    final container = containerWithList('list-1');
    final items = [
      {'text': 'Milk'},
    ];
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer((_) async => _page(const []));
    when(() => repo.createItems('list-1', items)).thenAnswer((_) async => const [ShoppingItem(id: 'i1', text: 'Milk')]);

    final count = await addShoppingItemsMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemWriterProvider).addItems(items),
    );

    expect(count, 1);
    verify(() => repo.createItems('list-1', items)).called(1);
    await Future<void>.delayed(Duration.zero);
    verifyNever(
      () => repo.findItems(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    );
  });

  test('addItems succeeds when the list is refreshed while the write is in flight', () async {
    final container = containerWithList('list-1');
    final items = [
      {'text': 'Milk'},
    ];
    final created = Completer<List<ShoppingItem>>();
    var fetches = 0;
    when(() => repo.findItems('list-1', limit: 20, offset: 0)).thenAnswer((_) async {
      fetches++;
      return _page(const []);
    });
    when(() => repo.createItems('list-1', items)).thenAnswer((_) => created.future);
    container.listen(shoppingItemsProvider, (_, _) {});
    await container.read(shoppingItemsProvider.future);

    final pending = addShoppingItemsMutation.run(
      container,
      (tsx) => tsx.get(shoppingItemWriterProvider).addItems(items),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(shoppingItemsProvider); // e.g. pull-to-refresh
    await container.read(shoppingItemsProvider.future);
    created.complete(const [ShoppingItem(id: 'i1', text: 'Milk')]);

    expect(await pending, 1);
    await container.read(shoppingItemsProvider.future);
    expect(fetches, 3, reason: 'initial load, the refresh, and the reload after the write');
  });
}
