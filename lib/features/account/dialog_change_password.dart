import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/password_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/util/validator.dart';
import 'section_current_password.dart';

/// Changes the password, confirmed with the current one.
class ChangePasswordBottomSheet extends HookConsumerWidget {
  const ChangePasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showAppBottomSheet<void>(context: context, builder: (_) => const ChangePasswordBottomSheet());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final currentController = useTextEditingController();
    final newController = useTextEditingController();
    final isSaving = ref.watch(changePasswordMutation).isPending;

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final saved = await changePasswordMutation.tryRun(
        ref,
        (tsx) => tsx.get(authProvider.notifier).changePassword(currentPassword: currentController.text, newPassword: newController.text),
      );
      if (!saved || !context.mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.accountPasswordChanged)));
    }

    return StandardBottomSheet(
      title: context.l10n.accountChangePassword,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurrentPasswordField(
              controller: currentController,
              mutation: changePasswordMutation,
              autofocus: true,
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            PasswordField(
              controller: newController,
              decoration: InputDecoration(
                labelText: context.l10n.accountNewPassword,
                helperText: context.l10n.accountOtherDevicesSignedOut,
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) => Validator.validatePassword(value, context.l10n),
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
