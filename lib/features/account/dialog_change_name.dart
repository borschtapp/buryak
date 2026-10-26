import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';

/// Changes the user's display name.
class ChangeNameBottomSheet extends ConsumerWidget {
  const ChangeNameBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(context: context, builder: (_) => const ChangeNameBottomSheet());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextInputDialog<void>(
      title: context.l10n.accountChangeName,
      labelText: context.l10n.accountName,
      hintText: context.l10n.registerNameHint,
      submitLabel: context.l10n.save,
      initialText: ref.read(authProvider)?.name,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.name],
      validator: (value) => Validator.validateName(value, context.l10n),
      mutation: changeNameMutation,
      onSubmit: (tsx, name) => tsx.get(authProvider.notifier).changeName(name),
    );
  }
}
