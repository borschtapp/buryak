import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import 'notifier_shopping.dart';

Future<void> showAddItemDialog(BuildContext context, WidgetRef ref) async {
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: 'Add Item',
      hintText: 'e.g. Milk',
      labelText: 'Product Name',
      submitLabel: 'Add',
      onSubmit: (value, context) async {
        await ref.read(shoppingItemsProvider.notifier).addItem(value);
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
