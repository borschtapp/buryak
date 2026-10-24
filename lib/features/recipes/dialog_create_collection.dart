import 'package:flutter/material.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/saved.dart';
import '../../shared/util/extensions.dart';

void showCreateCollectionDialog(BuildContext context) {
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => TextInputDialog(
      title: l10n.cookbookCreateTitle,
      labelText: l10n.cookbookCreateNameLabel,
      hintText: l10n.cookbookCreateNameHint,
      submitLabel: l10n.cookbookCreateSubmit,
      validator: (value) => value.isEmpty ? l10n.cookbookCreateNameRequired : null,
      mutation: createCollectionMutation,
      onSubmit: (tsx, name) => tsx.get(savedCollectionsProvider.notifier).create(name),
    ),
  );
}
