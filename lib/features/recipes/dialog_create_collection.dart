import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/widgets/text_input_dialog.dart';
import 'notifier_saved.dart';

void showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => TextInputDialog(
      title: 'New Cookbook',
      labelText: 'Name',
      hintText: 'My Favorite Recipes',
      submitLabel: 'Create',
      validator: (value) => value.isEmpty ? 'Name cannot be empty' : null,
      onSubmit: (name, ctx) async {
        await ref.read(savedCollectionsProvider.notifier).create(name);
        if (ctx.mounted) Navigator.pop(ctx);
      },
    ),
  );
}
