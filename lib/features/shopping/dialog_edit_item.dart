import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_indicator.dart';
import '../../shared/models/shopping_item.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'screen_shopping.dart';

class EditShoppingItemBottomSheet extends HookConsumerWidget {
  final ShoppingItem item;

  const EditShoppingItemBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAmount = item.amount != null;

    final nameController = useTextEditingController(text: item.text ?? '');
    final amountController = useTextEditingController(text: item.amount.formatAmount);
    final isSaving = useState(false);

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
            const SnackBar(content: Text('Item updated')),
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

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Edit item',
                  style: context.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
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
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => save(),
                  ),
                ),
                const SizedBox(width: 12),
                if (item.unit != null)
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        enabled: false,
                      ),
                      child: Text(item.unit!.name),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => save(),
            ),
          ] else
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Item',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => save(),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isSaving.value ? null : save,
            child: isSaving.value ? const LoadingIndicator() : const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
