import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_indicator.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'screen_shopping.dart';

class ShoppingBottomSheet extends HookConsumerWidget {
  final Recipe recipe;
  final ScrollController? scrollController;

  const ShoppingBottomSheet({super.key, required this.recipe, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIngredientIds = useState<Set<String>>(
      (recipe.ingredients ?? []).map((i) => i.id).toSet(),
    );
    final isSaving = useState(false);

    Future<void> save() async {
      isSaving.value = true;
      try {
        final selectedIngredients = recipe.ingredients?.where((i) => selectedIngredientIds.value.contains(i.id)).toList();

        if (selectedIngredients != null) {
          var listsResponse = await ref.read(shoppingListRepositoryProvider).findAll();
          var lists = listsResponse.data;
          if (lists.isEmpty) {
            final newList = await ref.read(shoppingListRepositoryProvider).create('Shopping List', isDefault: true);
            lists = [newList];
          }
          final primaryList = lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first);

          final repo = ref.read(shoppingListRepositoryProvider);
          final itemsToCreate = selectedIngredients
              .map(
                (ingredient) => {
                  'text': ingredient.displayName,
                  'amount': ingredient.amount,
                  'unit_id': ingredient.unitId,
                },
              )
              .toList();

          final createdItems = await repo.createItems(primaryList.id, itemsToCreate);
          final successCount = createdItems.length;

          ref.invalidate(shoppingItemsProvider);

          if (context.mounted) {
            context.pop();
            final message = successCount == selectedIngredients.length
                ? 'All ingredients added to shopping list'
                : 'Added $successCount of ${selectedIngredients.length} ingredients';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        }
      } catch (e) {
        ref.handleException(e);
      } finally {
        isSaving.value = false;
      }
    }

    final ingredients = useMemoized(
      () => (recipe.ingredients ?? []).where((i) => i.food?.pantry != true).toList(),
      [recipe.ingredients],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add to shopping', style: context.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
          const Divider(),
          if (ingredients.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No ingredients found for this recipe.'),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return CheckboxListTile(
                    value: selectedIngredientIds.value.contains(ingredient.id),
                    onChanged: (value) {
                      final newSet = Set<String>.from(selectedIngredientIds.value);
                      if (value == true) {
                        newSet.add(ingredient.id);
                      } else {
                        newSet.remove(ingredient.id);
                      }
                      selectedIngredientIds.value = newSet;
                    },
                    title: Text(ingredient.displayName),
                    subtitle: ingredient.displayAmount.isNotEmpty ? Text(ingredient.displayAmount) : null,
                  );
                },
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.paddingOf(context).bottom),
            child: FilledButton(
              onPressed: isSaving.value || selectedIngredientIds.value.isEmpty ? null : save,
              child: isSaving.value ? const LoadingIndicator() : const Text('Add to list'),
            ),
          ),
        ],
      ),
    );
  }
}
