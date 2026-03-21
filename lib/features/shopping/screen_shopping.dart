import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/extensions.dart';
import '../../shared/hooks.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import 'view_add_item_dialog.dart';

part 'screen_shopping.g.dart';

const int _pageSize = 20;

@Riverpod(keepAlive: true)
class ShoppingItems extends _$ShoppingItems {
  late String _primaryListId;
  late int _totalItems;

  @override
  FutureOr<ShoppingItemsState> build() async {
    var listsResponse = await ref.read(shoppingListRepositoryProvider).findAll();
    var lists = listsResponse.data;

    if (lists.isEmpty) {
      return ShoppingItemsState(items: [], hasMore: false, isLoading: false);
    }

    final primaryList = lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first);
    _primaryListId = primaryList.id;

    final itemsResponse = await ref
        .read(shoppingListRepositoryProvider)
        .findItems(
          primaryList.id,
          limit: _pageSize,
          offset: 0,
        );

    _totalItems = itemsResponse.meta.total;
    final hasMore = itemsResponse.data.length < _totalItems;

    return ShoppingItemsState(
      items: _sortItems(itemsResponse.data),
      hasMore: hasMore,
      isLoading: false,
    );
  }

  List<ShoppingItem> _sortItems(List<ShoppingItem> items) {
    return [...items]..sort((a, b) {
      if (a.isBought == b.isBought) return 0;
      if (a.isBought ?? false) return 1;
      return -1;
    });
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoading) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoading: true));

    try {
      final offset = currentState.items.length;
      final itemsResponse = await ref
          .read(shoppingListRepositoryProvider)
          .findItems(
            _primaryListId,
            limit: _pageSize,
            offset: offset,
          );

      final newItems = [...currentState.items, ...itemsResponse.data];
      final hasMore = newItems.length < _totalItems;

      state = AsyncData(
        currentState.copyWith(
          items: _sortItems(newItems),
          hasMore: hasMore,
          isLoading: false,
        ),
      );
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoading: false));
      rethrow;
    }
  }

  Future<void> toggleItem(ShoppingItem item) async {
    final newValue = !(item.isBought ?? false);

    // Optimistic Update
    final previousState = state;
    if (state.value != null) {
      final items = [...state.value!.items];
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item.copyWith(isBought: newValue);
        state = AsyncData(state.value!.copyWith(items: _sortItems(items)));
      }
    }

    try {
      await ref
          .read(shoppingListRepositoryProvider)
          .updateItem(
            _primaryListId,
            item.id,
            isBought: newValue,
          );
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    final previousState = state;

    // Optimistic update: remove item from the current state list
    state = state.whenData(
      (s) => s.copyWith(items: s.items.where((i) => i.id != id).toList()),
    );

    try {
      await ref.read(shoppingListRepositoryProvider).deleteItem(_primaryListId, id);
    } catch (e) {
      // Revert to previous state on failure
      state = previousState;
      rethrow;
    }
  }

  Future<void> addItem(String name) async {
    // We need the list ID. Find it from the current lists or re-fetch.
    final listsResponse = await ref.read(shoppingListRepositoryProvider).findAll();
    var lists = listsResponse.data;
    if (lists.isEmpty) {
      final newList = await ref.read(shoppingListRepositoryProvider).create('Shopping List', isDefault: true);
      lists = [newList];
    }
    final primaryList = lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first);
    _primaryListId = primaryList.id;

    final newItem = await ref.read(shoppingListRepositoryProvider).createItem(_primaryListId, name);

    if (state.value != null) {
      final items = [...state.value!.items];
      items.insert(0, newItem);
      _totalItems++;
      state = AsyncData(state.value!.copyWith(items: _sortItems(items)));
    } else {
      _totalItems = 1;
      state = AsyncData(ShoppingItemsState(items: [newItem], hasMore: false, isLoading: false));
    }
  }
}

class ShoppingItemsState {
  final List<ShoppingItem> items;
  final bool hasMore;
  final bool isLoading;

  ShoppingItemsState({
    required this.items,
    required this.hasMore,
    required this.isLoading,
  });

  ShoppingItemsState copyWith({
    List<ShoppingItem>? items,
    bool? hasMore,
    bool? isLoading,
  }) {
    return ShoppingItemsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
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

    return itemsAsync.when(
      data: (state) {
        if (state.items.isEmpty) {
          return EmptyStateView(
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
            itemCount: state.items.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (context, index) {
              if (index == state.items.length) return const SizedBox.shrink();
              return const Divider(height: 1);
            },
            itemBuilder: (context, index) {
              // Loading indicator at the end
              if (index == state.items.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: state.isLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
                );
              }

              final item = state.items[index];
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
      error: (err, stack) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(shoppingItemsProvider),
      ),
    );
  }
}
