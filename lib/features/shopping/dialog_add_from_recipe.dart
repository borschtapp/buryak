import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';
import 'notifier_shopping.dart';

class ShoppingBottomSheet extends HookConsumerWidget {
  final Recipe recipe;
  final ScrollController? scrollController;

  const ShoppingBottomSheet({super.key, required this.recipe, this.scrollController});

  static void show(BuildContext context, Recipe recipe) {
    // The sheet's parent already excludes the status bar (`useSafeArea`), so stop
    // one toolbar below it.
    final availableHeight = MediaQuery.heightOf(context) - MediaQuery.paddingOf(context).top;
    final maxFraction = (availableHeight - kToolbarHeight) / availableHeight;

    showAppBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: maxFraction,
        expand: false,
        snap: true,
        snapSizes: maxFraction > 0.55 ? const [0.5] : null,
        shouldCloseOnMinExtent: true,
        builder: (context, scrollController) => ShoppingBottomSheet(
          recipe: recipe,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIngredientIds = useState<Set<String>>(
      (recipe.ingredients ?? []).map((i) => i.id).toSet(),
    );
    final isSaving = ref.watch(addShoppingItemsMutation).isPending;

    Future<void> save() async {
      final selectedIngredients = recipe.ingredients?.where((i) => selectedIngredientIds.value.contains(i.id)).toList();
      if (selectedIngredients == null) return;

      final itemsToCreate = selectedIngredients
          .map(
            (ingredient) => {
              'text': ingredient.displayName,
              'amount': ingredient.amount,
              'unit_id': ingredient.unitId,
            },
          )
          .toList();

      final int successCount;
      try {
        successCount = await addShoppingItemsMutation.run(
          ref,
          (tsx) => tsx.get(shoppingItemsProvider.notifier).addItems(itemsToCreate),
        );
      } on Object {
        return; // Already reported by MutationErrorReporter.
      }

      if (!context.mounted) return;
      context.pop();
      final l10n = context.l10n;
      final message = successCount == selectedIngredients.length
          ? l10n.shoppingAllIngredientsAdded
          : l10n.shoppingPartialIngredientsAdded(successCount, selectedIngredients.length);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    final ingredients = useMemoized(
      () => (recipe.ingredients ?? []).where((i) => i.food?.pantry != true).toList(),
      [recipe.ingredients],
    );

    return StandardBottomSheet(
      title: context.l10n.shoppingAddToShoppingTitle,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      // Bounded by the draggable sheet, so a long ingredient list scrolls instead of overflowing.
      expandChild: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(context.l10n.shoppingNoIngredients),
            )
          else
            Flexible(
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
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
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
            child: LoadingButton(
              isLoading: isSaving,
              onPressed: selectedIngredientIds.value.isEmpty ? null : save,
              child: Text(context.l10n.shoppingAddToList),
            ),
          ),
        ],
      ),
    );
  }
}
