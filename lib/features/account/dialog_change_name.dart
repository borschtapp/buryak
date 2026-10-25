import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';

Future<void> showChangeNameDialog(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => TextInputDialog(
      title: l10n.accountChangeName,
      hintText: l10n.registerNameHint,
      labelText: l10n.accountName,
      submitLabel: l10n.save,
      initialText: ref.read(authProvider)?.name,
      validator: (value) => Validator.validateName(value, l10n),
      mutation: changeNameMutation,
      onSubmit: (tsx, value) => tsx.get(authProvider.notifier).changeName(value),
    ),
  );
}
