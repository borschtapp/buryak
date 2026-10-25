import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/recipe_ingredient.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/providers/shopping.dart';
import '../../shared/repositories/shopping_list_repository.dart';

part 'notifier_shopping.g.dart';

/// The server rejects item text longer than this.
const shoppingItemTextMaxLength = 255;

// Run with `tsx.get(shoppingItemsProvider.notifier)`.
final addShoppingItemMutation = Mutation<void>(label: 'addShoppingItem');
final updateShoppingItemMutation = Mutation<void>(label: 'updateShoppingItem');

// Run with `tsx.get(shoppingItemWriterProvider)`.
final addShoppingItemsMutation = Mutation<void>(label: 'addShoppingItems');

@Riverpod(keepAlive: true)
ShoppingItemWriter shoppingItemWriter(Ref ref) => ShoppingItemWriter(ref);

/// Adds items from outside the shopping screen. Kept off [ShoppingItems] so
/// adding a recipe's ingredients doesn't load a list nobody is showing.
class ShoppingItemWriter {
  ShoppingItemWriter(this._ref);

  final Ref _ref;

  /// Adds [ingredients] to the primary list, linked to their food. The server saves
  /// all of them or none, and merges items of the same food into one row.
  Future<void> addIngredients(List<RecipeIngredient> ingredients) async {
    final listId = await _ref.read(primaryShoppingListIdProvider.future);
    await _ref.read(shoppingListRepositoryProvider).createItems(listId, [
      for (final i in ingredients) (text: i.displayName, amount: i.amount, unitId: i.unitId, foodId: i.foodId),
    ]);
    // Reloads the list only if it was loaded.
    _ref.invalidate(shoppingItemsProvider);
  }
}

@Riverpod(keepAlive: true)
class ShoppingItems extends _$ShoppingItems with PagedNotifierMixin<ShoppingItem> {
  // The household's default list can't be deleted or replaced (backend
  // `ShoppingListService`), so its cached id stays valid until the session
  // changes. Read it per call rather than caching it in [build]: a write can
  // run before the list has finished loading.
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
    final newItem = await ref.read(shoppingListRepositoryProvider).createItem(await _listId, (
      text: name,
      amount: null,
      unitId: null,
      foodId: null,
    ));

    // The server keeps one row per food, so it may return an existing row (with the
    // amounts added, or a bought one unchecked); move that row to the top instead of
    // adding a second one. The returned row is never bought, so the order stays sorted.
    state = AsyncData([newItem, ...?state.value?.where((i) => i.id != newItem.id)]);
  }
}
