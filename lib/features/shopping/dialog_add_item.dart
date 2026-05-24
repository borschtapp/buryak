import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/util/extensions.dart';
import 'notifier_shopping.dart';

Future<void> showAddItemDialog(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: l10n.shoppingAddItemTitle,
      hintText: l10n.shoppingAddItemHint,
      labelText: l10n.shoppingAddItemLabel,
      submitLabel: l10n.importAddSubmit,
      onSubmit: (value, context) async {
        await ref.read(shoppingItemsProvider.notifier).addItem(value);
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
