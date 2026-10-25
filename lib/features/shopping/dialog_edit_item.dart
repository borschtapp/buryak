import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/food_merge.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/providers/food_catalog.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'notifier_shopping.dart';

final _amountPattern = RegExp(r'^\d*[.,]?\d*$');

class EditShoppingItemBottomSheet extends HookConsumerWidget {
  final ShoppingItem item;

  const EditShoppingItemBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A linked food or unit keeps the field after its amount is cleared, so it can be set again.
    final hasAmount = item.amount != null || item.foodId != null || item.unitId != null;

    final nameController = useTextEditingController(text: item.text ?? '');
    final amountController = useTextEditingController(text: item.amount.formatAmount);
    final isSaving = ref.watch(updateShoppingItemMutation).isPending;
    final isMerging = ref.watch(mergeFoodsMutation).isPending;

    // Free-text items have no linked canonical food, so there is nothing to merge.
    final food = item.food;

    Future<void> merge() async {
      if (food == null) return;
      // Merge is global; the catalog refreshes the list so the alias rows collapse.
      final merged = await runFoodMergeFlow(context, ref, source: food);
      if (!merged || !context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shoppingItemMerged)),
      );
    }

    Future<void> save() async {
      final name = nameController.text.trim();
      if (name.isEmpty) return;

      final amountText = amountController.text.trim();
      final parsedAmount = amountText.asDecimal;
      // Empty or zero clears the amount (the server rejects 0); text that
      // doesn't parse keeps the old one.
      final amount = amountText.isEmpty || parsedAmount == 0 ? null : (parsedAmount ?? item.amount);
      final saved = await updateShoppingItemMutation.tryRun(
        ref,
        (tsx) => tsx.get(shoppingItemsProvider.notifier).updateItem(item, text: name, amount: amount),
      );
      if (!saved || !context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.shoppingItemUpdated)),
      );
    }

    return StandardBottomSheet(
      title: context.l10n.shoppingEditItem,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasAmount) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: amountController,
                    // An item kept only for its food (e.g. "Salt") is opened to rename it.
                    autofocus: item.amount != null,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    // Reject (rather than trim) any edit that isn't a number with at most one
                    // decimal separator, so input like '1.000,5' can't be typed.
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => _amountPattern.hasMatch(newValue.text) ? newValue : oldValue,
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.shoppingItemAmount,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => save(),
                  ),
                ),
                const SizedBox(width: 12),
                if (item.unit != null)
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.l10n.shoppingItemUnit,
                        border: const OutlineInputBorder(),
                        enabled: false,
                      ),
                      child: Text(item.unit!.name),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            TextField(
              controller: nameController,
              autofocus: item.amount == null,
              decoration: InputDecoration(
                labelText: context.l10n.shoppingItemName,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => save(),
            ),
          ] else
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: context.l10n.shoppingItemField,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => save(),
            ),
          const SizedBox(height: UIConstants.paddingLarge),
          LoadingButton(
            isLoading: isSaving,
            onPressed: save,
            child: Text(context.l10n.saveChanges),
          ),
          if (food != null) ...[
            const SizedBox(height: UIConstants.paddingSmall),
            LoadingButton(
              type: LoadingButtonType.text,
              isLoading: isMerging,
              icon: const Icon(Icons.merge_outlined),
              onPressed: (isSaving || isMerging) ? null : merge,
              spinnerSize: 16,
              child: Text(context.l10n.shoppingItemMergeFood),
            ),
          ],
        ],
      ),
    );
  }
}
