import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/recipe.dart';
import '../../shared/util/error_extensions.dart';
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
    // Pantry staples are hidden, so they must not be selected (and added) either.
    final ingredients = useMemoized(
      () => (recipe.ingredients ?? []).where((i) => i.food?.pantry != true).toList(),
      [recipe.ingredients],
    );
    final selectedIngredientIds = useState<Set<String>>(
      ingredients.map((i) => i.id).toSet(),
    );
    final isSaving = ref.watch(addShoppingItemsMutation).isPending;

    Future<void> save() async {
      final selected = ingredients.where((i) => selectedIngredientIds.value.contains(i.id)).toList();
      final added = await addShoppingItemsMutation.tryRun(
        ref,
        (tsx) => tsx.get(shoppingItemWriterProvider).addIngredients(selected),
      );
      if (!added || !context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shoppingAllIngredientsAdded)),
      );
    }

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
