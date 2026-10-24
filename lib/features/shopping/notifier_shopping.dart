import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/shopping_item.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/providers/shopping.dart';
import '../../shared/repositories/shopping_list_repository.dart';

part 'notifier_shopping.g.dart';

// Run with `tsx.get(shoppingItemsProvider.notifier)`.
final addShoppingItemsMutation = Mutation<int>(label: 'addShoppingItems');
final updateShoppingItemMutation = Mutation<void>(label: 'updateShoppingItem');

@Riverpod(keepAlive: true)
class ShoppingItems extends _$ShoppingItems with PagedNotifierMixin<ShoppingItem> {
  // The household's default list can't be deleted or replaced (backend
  // `ShoppingListService`), so its cached id stays valid until the session
  // changes. Read it per call rather than caching it in [build]: writes such as
  // [addItems] can run before the list has ever loaded.
  Future<String> get _listId => ref.read(primaryShoppingListIdProvider.future);

  @override
  int get limit => 20;

  @override
  List<ShoppingItem> Function(List<ShoppingItem>)? get sortItems => _sortItems;

  @override
  Future<List<ShoppingItem>> build() async {
    resetPagination();
    final listId = await ref.watch(primaryShoppingListIdProvider.future);

    final itemsResponse = await ref.read(shoppingListRepositoryProvider).findItems(listId, limit: limit, offset: 0);
    return itemsResponse.data;
  }

  List<ShoppingItem> _sortItems(List<ShoppingItem> items) {
    return [...items]..sort((a, b) {
      if (a.isBought == b.isBought) return 0;
      if (a.isBought ?? false) return 1;
      return -1;
    });
  }

  Future<void> loadMore() => loadNextPage((offset, pageLimit) async {
    return ref.read(shoppingListRepositoryProvider).findItems(await _listId, limit: pageLimit, offset: offset);
  });

  Future<void> toggleItem(ShoppingItem item) async {
    final newValue = !(item.isBought ?? false);

    final previousState = state;
    if (state.value != null) {
      final items = [...state.value!];
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = items[index].copyWith(isBought: newValue);
        state = AsyncData(_sortItems(items));
      }
    }

    try {
      await ref.read(shoppingListRepositoryProvider).updateItem(await _listId, item.id, isBought: newValue);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    final previousState = state;

    state = state.whenData((items) => items.where((i) => i.id != id).toList());

    try {
      await ref.read(shoppingListRepositoryProvider).deleteItem(await _listId, id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  /// Saves the edit form; a null [amount] clears it.
  Future<void> updateItem(ShoppingItem item, {required String text, required double? amount}) async {
    final previousState = state;

    if (state.value != null) {
      final items = [...state.value!];
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = items[index].copyWith(text: text, amount: amount);
        state = AsyncData(items);
      }
    }

    try {
      await ref
          .read(shoppingListRepositoryProvider)
          .updateItem(await _listId, item.id, text: text, amount: amount, clearAmount: amount == null);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> addItem(String name) async {
    final newItem = await ref.read(shoppingListRepositoryProvider).createItem(await _listId, name);

    if (state.value != null) {
      final items = [...state.value!];
      items.insert(0, newItem);
      state = AsyncData(items);
    } else {
      state = AsyncData([newItem]);
    }
  }

  /// Adds [items] to the primary list and returns how many were created.
  Future<int> addItems(List<Map<String, dynamic>> items) async {
    final created = await ref.read(shoppingListRepositoryProvider).createItems(await _listId, items);
    // Last step: rebuilding replaces this notifier, so nothing after it may use ref or state.
    ref.invalidateSelf();
    return created.length;
  }
}
