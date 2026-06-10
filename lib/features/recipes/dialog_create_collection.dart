import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/saved.dart';
import '../../shared/util/extensions.dart';

void showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => TextInputDialog(
      title: context.l10n.cookbookCreateTitle,
      labelText: context.l10n.cookbookCreateNameLabel,
      hintText: context.l10n.cookbookCreateNameHint,
      submitLabel: context.l10n.cookbookCreateSubmit,
      validator: (value) => value.isEmpty ? context.l10n.cookbookCreateNameRequired : null,
      onSubmit: (name, ctx) async {
        await ref.read(savedCollectionsProvider.notifier).create(name);
        if (ctx.mounted) Navigator.pop(ctx);
      },
    ),
  );
}
