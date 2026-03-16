import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'screen_shopping.dart';

Future<void> showAddItemDialog(BuildContext context, WidgetRef ref) async {
  final name = await showDialog<String>(
    context: context,
    builder: (context) => const _AddItemDialog(),
  );

  if (name != null && name.trim().isNotEmpty) {
    try {
      await ref.read(shoppingItemsProvider.notifier).addItem(name.trim());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add item.')),
        );
      }
    }
  }
}

class _AddItemDialog extends HookConsumerWidget {
  const _AddItemDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    return AlertDialog(
      title: const Text('Add Item'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Product Name', hintText: 'e.g. Milk'),
        onSubmitted: (val) => Navigator.pop(context, val),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
      ],
    );
  }
}
