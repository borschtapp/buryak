import 'package:flutter/material.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/util/extensions.dart';
import 'notifier_shopping.dart';

Future<void> showAddItemDialog(BuildContext context) async {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: l10n.shoppingAddItemTitle,
      hintText: l10n.shoppingAddItemHint,
      labelText: l10n.shoppingAddItemLabel,
      submitLabel: l10n.importAddSubmit,
      mutation: addShoppingItemMutation,
      onSubmit: (tsx, value) => tsx.get(shoppingItemsProvider.notifier).addItem(value),
    ),
  );
}
