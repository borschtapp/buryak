import 'package:flutter/material.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/extensions.dart';

Future<void> showJoinHouseholdDialog(BuildContext context, {String? initialCode}) async {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => TextInputDialog(
      title: l10n.householdJoinHousehold,
      hintText: l10n.householdJoinInviteCodeHint,
      labelText: l10n.householdJoinInviteCode,
      submitLabel: l10n.householdJoinSubmit,
      helperText: l10n.householdJoinHelper,
      initialText: initialCode,
      validator: (value) => value.isEmpty ? l10n.householdJoinCodeRequired : null,
      mutation: joinHouseholdMutation,
      onSubmit: (tsx, value) => tsx.get(householdProvider.notifier).joinHousehold(value),
      onSuccess: (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.householdJoinSuccess)),
        );
      },
    ),
  );
}
