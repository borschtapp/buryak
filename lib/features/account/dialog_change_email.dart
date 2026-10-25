import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/util/validator.dart';
import 'section_current_password.dart';

/// Changes the sign-in email, confirmed with the current password.
class ChangeEmailBottomSheet extends HookConsumerWidget {
  const ChangeEmailBottomSheet({super.key});

  static void show(BuildContext context) {
    showAppBottomSheet<void>(context: context, builder: (_) => const ChangeEmailBottomSheet());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController(text: ref.read(authProvider)?.email);
    final passwordController = useTextEditingController();
    final isSaving = ref.watch(changeEmailMutation).isPending;

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final saved = await changeEmailMutation.tryRun(
        ref,
        (tsx) => tsx.get(authProvider.notifier).changeEmail(emailController.text.trim(), currentPassword: passwordController.text),
      );
      if (!saved || !context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.accountEmailUpdated)));
    }

    return StandardBottomSheet(
      title: context.l10n.accountChangeEmail,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: (value) => Validator.validateEmail(value ?? '', context.l10n),
              decoration: InputDecoration(
                labelText: context.l10n.accountNewEmail,
                helperText: context.l10n.accountOtherDevicesSignedOut,
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            CurrentPasswordField(
              controller: passwordController,
              mutation: changeEmailMutation,
              onFieldSubmitted: (_) => save(),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            LoadingButton(
              isLoading: isSaving,
              onPressed: save,
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
