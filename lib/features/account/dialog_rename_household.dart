import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/extensions.dart';

Future<void> showRenameHouseholdDialog(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final currentName = ref.read(householdProvider).value?.name;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: l10n.householdRenameHousehold,
      hintText: l10n.householdRenameNameHint,
      labelText: l10n.householdRenameName,
      submitLabel: l10n.save,
      initialText: currentName,
      validator: (value) => value.trim().isEmpty ? l10n.householdRenameNameRequired : null,
      onSubmit: (value, context) async {
        await ref.read(householdProvider.notifier).updateHousehold(name: value.trim());
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
