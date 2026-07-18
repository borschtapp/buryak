import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dismissible_tile.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/hooks.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'dialog_add_item.dart';
import 'dialog_edit_item.dart';
import 'notifier_shopping.dart';

class ShoppingScreen extends HookConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useFab(
      ref,
      FloatingActionButton(
        heroTag: 'shopping_add_fab',
        onPressed: () => showAddItemDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );

    final itemsAsync = ref.watch(shoppingItemsProvider);
    final notifier = ref.read(shoppingItemsProvider.notifier);

    return AppListScaffold<List<ShoppingItem>>(
      value: itemsAsync,
      onRefresh: () async => ref.invalidate(shoppingItemsProvider),
      onLoadMore: notifier.loadMore,
      isLoadingMore: notifier.isLoadingMore,
      hasMore: notifier.hasMore,
      isEmpty: (items) => items.isEmpty,
      emptyState: EmptyState(
        icon: Icons.shopping_basket_outlined,
        title: context.l10n.shoppingEmptyTitle,
        subtitle: context.l10n.shoppingEmptySubtitle,
        action: TextButton.icon(
          onPressed: () => ref.invalidate(shoppingItemsProvider),
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.refresh),
        ),
      ),
      data: (items) => ListView.separated(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          void openEditSheet() {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => EditShoppingItemBottomSheet(item: item),
            );
          }

          return DismissibleTile(
            key: ValueKey(item.id),
            label: item.text ?? context.l10n.shoppingItemField,
            onEdit: openEditSheet,
            onDelete: () async {
              try {
                await ref.read(shoppingItemsProvider.notifier).deleteItem(item.id);
              } catch (e) {
                ref.handleException(e);
              }
            },
            child: ListTile(
              onLongPress: openEditSheet,
              leading: Checkbox(
                value: item.isBought ?? false,
                semanticLabel: context.l10n.shoppingMarkAsBought(item.text ?? context.l10n.shoppingItemField),
                onChanged: (_) async {
                  try {
                    await ref.read(shoppingItemsProvider.notifier).toggleItem(item);
                  } catch (e) {
                    ref.handleException(e);
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
                      '${item.amount.displayAmount} ${item.unit?.name ?? ''}'.trim(),
                      style: context.textTheme.bodySmall,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
