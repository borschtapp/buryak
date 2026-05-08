import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/shopping_item.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/providers/shopping.dart';
import '../../shared/repositories/shopping_list_repository.dart';

part 'notifier_shopping.g.dart';

@Riverpod(keepAlive: true)
class ShoppingItems extends _$ShoppingItems with PagedNotifierMixin<ShoppingItem> {
  late String _primaryListId;

  @override
  int get limit => 20;

  @override
  List<ShoppingItem> Function(List<ShoppingItem>)? get sortItems => _sortItems;

  @override
  Future<List<ShoppingItem>> build() async {
    resetPagination();
    _primaryListId = await ref.read(primaryShoppingListIdProvider.future);

    final itemsResponse = await ref.read(shoppingListRepositoryProvider).findItems(_primaryListId, limit: limit, offset: 0);
    return itemsResponse.data;
  }

  List<ShoppingItem> _sortItems(List<ShoppingItem> items) {
    return [...items]..sort((a, b) {
      if (a.isBought == b.isBought) return 0;
      if (a.isBought ?? false) return 1;
      return -1;
    });
  }

  Future<void> loadMore() => loadNextPage((offset, pageLimit) {
    return ref.read(shoppingListRepositoryProvider).findItems(_primaryListId, limit: pageLimit, offset: offset);
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
      await ref.read(shoppingListRepositoryProvider).updateItem(_primaryListId, item.id, isBought: newValue);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    final previousState = state;

    state = state.whenData((items) => items.where((i) => i.id != id).toList());

    try {
      await ref.read(shoppingListRepositoryProvider).deleteItem(_primaryListId, id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateItem(ShoppingItem item, {String? text, double? amount}) async {
    final previousState = state;

    if (state.value != null) {
      final items = [...state.value!];
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = items[index].copyWith(text: text ?? items[index].text, amount: amount);
        state = AsyncData(items);
      }
    }

    try {
      await ref.read(shoppingListRepositoryProvider).updateItem(_primaryListId, item.id, text: text, amount: amount);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> addItem(String name) async {
    final newItem = await ref.read(shoppingListRepositoryProvider).createItem(_primaryListId, name);

    if (state.value != null) {
      final items = [...state.value!];
      items.insert(0, newItem);
      state = AsyncData(items);
    } else {
      state = AsyncData([newItem]);
    }
  }
}
