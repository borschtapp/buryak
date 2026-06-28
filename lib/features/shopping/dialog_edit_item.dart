import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/food_merge.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'notifier_shopping.dart';

class EditShoppingItemBottomSheet extends HookConsumerWidget {
  final ShoppingItem item;

  const EditShoppingItemBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAmount = item.amount != null;

    final nameController = useTextEditingController(text: item.text ?? '');
    final amountController = useTextEditingController(text: item.amount.formatAmount);
    final isSaving = useState(false);
    final isMerging = useState(false);

    // Free-text items have no linked canonical food, so there is nothing to merge.
    final food = item.food;

    Future<void> merge() async {
      if (food == null) return;
      isMerging.value = true;
      try {
        final merged = await runFoodMergeFlow(context, ref, source: food);
        if (merged) {
          // Merge is global; refresh the whole list so the alias rows collapse.
          ref.invalidate(shoppingItemsProvider);
          if (context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.shoppingItemMerged)),
            );
          }
        }
      } finally {
        if (context.mounted) isMerging.value = false;
      }
    }

    Future<void> save() async {
      final name = nameController.text.trim();
      if (name.isEmpty) return;

      isSaving.value = true;
      try {
        final amountText = amountController.text.trim();
        // if amount was present, preserve it on parse failure
        final amount = hasAmount ? (double.tryParse(amountText) ?? item.amount) : double.tryParse(amountText);
        await ref.read(shoppingItemsProvider.notifier).updateItem(item, text: name, amount: amount);

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.shoppingItemUpdated)),
          );
        }
      } catch (e) {
        ref.handleException(e);
      } finally {
        if (context.mounted) {
          isSaving.value = false;
        }
      }
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
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
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
            isLoading: isSaving.value,
            onPressed: save,
            child: Text(context.l10n.saveChanges),
          ),
          if (food != null) ...[
            const SizedBox(height: UIConstants.paddingSmall),
            LoadingButton(
              type: LoadingButtonType.text,
              isLoading: isMerging.value,
              icon: const Icon(Icons.merge_outlined),
              onPressed: (isSaving.value || isMerging.value) ? null : merge,
              spinnerSize: 16,
              child: Text(context.l10n.shoppingItemMergeFood),
            ),
          ],
        ],
      ),
    );
  }
}
