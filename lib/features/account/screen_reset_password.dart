import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/password_field.dart';
import '../../shared/layouts/standard_auth_form.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final passwordController = useTextEditingController();

    Future<void> submit() async {
      if (isLoading.value) return;
      if (formKey.currentState?.validate() ?? false) {
        isLoading.value = true;
        try {
          await ref.read(authRepositoryProvider).resetPassword(token, passwordController.text);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.resetPasswordSuccess)),
            );
            context.goNamed(RouteNames.login);
          }
        } catch (e) {
          ref.handleException(e);
        } finally {
          if (context.mounted) isLoading.value = false;
        }
      }
    }

    return StandardAuthForm(
      title: context.l10n.resetPasswordTitle,
      subtitle: context.l10n.resetPasswordSubtitle,
      formKey: formKey,
      isLoading: isLoading.value,
      onSubmit: submit,
      submitLabel: context.l10n.resetPasswordSubmit,
      secondaryButton: TextButton(
        onPressed: () => context.goNamed(RouteNames.login),
        child: Text(context.l10n.resetPasswordBackToLogin),
      ),
      children: [
        PasswordField(
          controller: passwordController,
          onFieldSubmitted: (_) => submit(),
          autofillHints: const [AutofillHints.newPassword],
          validator: (value) => Validator.validatePassword(value, context.l10n),
          decoration: InputDecoration(
            labelText: context.l10n.resetPasswordNewPassword,
            hintText: context.l10n.loginPasswordHint,
          ),
        ),
      ],
    );
  }
}
