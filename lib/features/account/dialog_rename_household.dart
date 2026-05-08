import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/household.dart';

Future<void> showRenameHouseholdDialog(BuildContext context, WidgetRef ref) async {
  final currentName = ref.read(householdProvider).value?.name;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: 'Rename Household',
      hintText: 'My Kitchen',
      labelText: 'Household Name',
      submitLabel: 'Save',
      initialText: currentName,
      validator: (value) => value.trim().isEmpty ? 'Name is required' : null,
      onSubmit: (value, context) async {
        await ref.read(householdProvider.notifier).rename(value.trim());
        if (context.mounted) Navigator.pop(context);
      },
    ),
  );
}
