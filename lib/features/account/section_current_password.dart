import 'package:flutter/material.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/password_field.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/extensions.dart';

/// The current password that confirms a credential change run by [mutation].
/// Shows the server's rejection inline and clears it once the user edits the field.
class CurrentPasswordField extends ConsumerWidget {
  const CurrentPasswordField({
    super.key,
    required this.controller,
    required this.mutation,
    this.autofocus = false,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final Mutation<void> mutation;
  final bool autofocus;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mutation);
    final wrongPassword = state is MutationError && state.error is WrongPasswordException;

    return PasswordField(
      controller: controller,
      decoration: InputDecoration(
        labelText: context.l10n.accountCurrentPassword,
        errorText: wrongPassword ? context.l10n.accountWrongPassword : null,
        border: const OutlineInputBorder(),
      ),
      autofocus: autofocus,
      autofillHints: const [AutofillHints.password],
      validator: (value) => value.isEmpty ? context.l10n.validatorFieldRequired : null,
      onChanged: (_) {
        if (wrongPassword) mutation.reset(ref);
      },
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
