import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/components/error_state.dart';
import '../../shared/hooks.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/providers/shopping.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/util/extensions.dart';
import 'dialog_add_item.dart';

part 'screen_shopping.g.dart';

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
    var listsResponse = await ref.read(shoppingListRepositoryProvider).findAll();
    var lists = listsResponse.data;

    if (lists.isEmpty) {
      _primaryListId = '';
      return [];
    }

    final primaryList = lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first);
    _primaryListId = primaryList.id;

    final itemsResponse = await ref.read(shoppingListRepositoryProvider).findItems(primaryList.id, limit: limit, offset: 0);
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

    // Optimistic update: find and toggle the item
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

    // Optimistic update: remove item from the current state list
    state = state.whenData((items) => items.where((i) => i.id != id).toList());

    try {
      await ref.read(shoppingListRepositoryProvider).deleteItem(_primaryListId, id);
    } catch (e) {
      // Revert to previous state on failure
      state = previousState;
      rethrow;
    }
  }

  Future<void> addItem(String name) async {
    // Get the primary list ID from cache (or fetch if not cached)
    final primaryListId = await ref.read(primaryShoppingListIdProvider.future);
    _primaryListId = primaryListId;
    final newItem = await ref.read(shoppingListRepositoryProvider).createItem(primaryListId, name);

    if (state.value != null) {
      final items = [...state.value!];
      // New items are not bought, so insert at beginning (before any bought items)
      items.insert(0, newItem);
      state = AsyncData(items);
    } else {
      state = AsyncData([newItem]);
    }
  }
}

class ShoppingScreen extends HookConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    useFab(
      ref,
      FloatingActionButton(
        heroTag: 'shopping_add_fab',
        onPressed: () => showAddItemDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );

    useEffect(
      () {
        void onScroll() {
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 500) {
            ref.read(shoppingItemsProvider.notifier).loadMore();
          }
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [scrollController, ref],
    );

    final itemsAsync = ref.watch(shoppingItemsProvider);
    final notifier = ref.read(shoppingItemsProvider.notifier);

    return itemsAsync.when(
      data: (List<ShoppingItem> items) {
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_basket_outlined,
            title: 'Your shopping list is empty',
            subtitle: 'Tap the + button to add items you need for your recipes.',
            action: TextButton.icon(
              onPressed: () => ref.invalidate(shoppingItemsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(shoppingItemsProvider),
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: items.length + (notifier.hasMore ? 1 : 0),
            separatorBuilder: (context, index) {
              if (index == items.length) return const SizedBox.shrink();
              return const Divider(height: 1);
            },
            itemBuilder: (context, index) {
              if (index == items.length) {
                return notifier.isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }

              final item = items[index];
              return Dismissible(
                key: ValueKey(item.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  final itemName = item.text ?? 'Item';
                  try {
                    await ref.read(shoppingItemsProvider.notifier).deleteItem(item.id);
                    if (context.mounted) {
                      SemanticsService.sendAnnouncement(View.of(context), '$itemName removed', TextDirection.ltr);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete item.')),
                      );
                    }
                  }
                },
                child: ListTile(
                  leading: Checkbox(
                    value: item.isBought ?? false,
                    semanticLabel: 'Mark ${item.text ?? "item"} as bought',
                    onChanged: (_) async {
                      try {
                        await ref.read(shoppingItemsProvider.notifier).toggleItem(item);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update item.')),
                          );
                        }
                      }
                    },
                  ),
                  title: Text(
                    item.text ?? '',
                    style: (item.isBought ?? false)
                        ? context.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: context.colors.onSurfaceVariant,
                          )
                        : null,
                  ),
                  subtitle: item.amount != null
                      ? Text(
                          '${item.amount} ${item.unit?.name ?? ''}',
                          style: context.textTheme.bodySmall,
                        )
                      : null,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(shoppingItemsProvider),
      ),
    );
  }
}
