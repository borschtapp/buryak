import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/extensions.dart';

Future<void> showJoinHouseholdDialog(BuildContext context, WidgetRef ref, {String? initialCode}) async {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: l10n.householdJoinHousehold,
      hintText: l10n.householdJoinInviteCodeHint,
      labelText: l10n.householdJoinInviteCode,
      submitLabel: l10n.householdJoinSubmit,
      helperText: l10n.householdJoinHelper,
      validator: (value) => value.trim().isEmpty ? l10n.householdJoinCodeRequired : null,
      onSubmit: (value, context) async {
        await ref.read(householdProvider.notifier).joinHousehold(value.trim());
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.householdJoinSuccess)),
          );
        }
      },
    ),
  );
}
