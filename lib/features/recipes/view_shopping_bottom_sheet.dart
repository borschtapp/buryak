import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/extensions.dart';
import '../../features/shopping/screen_shopping.dart';

class AddToShoppingBottomSheet extends HookConsumerWidget {
  final Recipe recipe;

  const AddToShoppingBottomSheet({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIngredientIds = useState<Set<String>>(
      (recipe.ingredients ?? []).map((i) => i.id).toSet(),
    );
    final isSaving = useState(false);

    Future<void> save() async {
      isSaving.value = true;
      try {
        final selectedIngredients = recipe.ingredients
            ?.where((i) => selectedIngredientIds.value.contains(i.id))
            .toList();

        if (selectedIngredients != null) {
          var listsResponse = await ref.read(shoppingListRepositoryProvider).findAll();
          var lists = listsResponse.data;
          if (lists.isEmpty) {
            final newList = await ref.read(shoppingListRepositoryProvider).create('Shopping List', isDefault: true);
            lists = [newList];
          }
          final primaryList = lists.firstWhere((l) => l.isDefault ?? false, orElse: () => lists.first);

          final repo = ref.read(shoppingListRepositoryProvider);
          final results = await Future.wait(
            // TODO: use batch insert
            selectedIngredients.map((ingredient) async {
              try {
                await repo.createItem(
                  primaryList.id,
                  ingredient.displayName,
                  amount: ingredient.amount,
                  unitId: ingredient.unitId,
                );
                return true;
              } catch (e) {
                debugPrint('Failed to add ${ingredient.displayName}: $e');
                return false;
              }
            }),
          );
          final successCount = results.where((r) => r).length;

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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    final ingredients = recipe.ingredients ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No ingredients found for this recipe.'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return CheckboxListTile(
                    autofocus: index == 0,
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
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: isSaving.value || selectedIngredientIds.value.isEmpty ? null : save,
              child: isSaving.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add to list'),
            ),
          ),
        ],
      ),
    );
  }
}
