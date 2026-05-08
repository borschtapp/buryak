import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/household.dart';

Future<void> showJoinHouseholdDialog(BuildContext context, WidgetRef ref, {String? initialCode}) async {
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: 'Join Household',
      hintText: 'ABCD-1234',
      labelText: 'Invite Code',
      submitLabel: 'Join',
      helperText: 'Enter the invite code shared with you to join their household.',
      validator: (value) => value.trim().isEmpty ? 'Code is required' : null,
      onSubmit: (value, context) async {
        await ref.read(householdProvider.notifier).joinHousehold(value.trim());
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully joined household!')),
          );
        }
      },
    ),
  );
}
