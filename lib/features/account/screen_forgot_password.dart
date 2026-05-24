import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/layouts/standard_auth_form.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';

class ForgotPasswordScreen extends HookConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();

    Future<void> submit() async {
      if (isLoading.value) return;
      if (formKey.currentState?.validate() ?? false) {
        isLoading.value = true;
        try {
          await ref.read(authRepositoryProvider).forgotPassword(emailController.text);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.forgotPasswordSuccess)),
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
      title: context.l10n.forgotPasswordTitle,
      subtitle: context.l10n.forgotPasswordSubtitle,
      formKey: formKey,
      isLoading: isLoading.value,
      onSubmit: submit,
      submitLabel: context.l10n.forgotPasswordSubmit,
      secondaryButton: TextButton(
        onPressed: () => context.goNamed(RouteNames.login),
        child: Text(context.l10n.forgotPasswordBackToLogin),
      ),
      children: [
        TextFormField(
          controller: emailController,
          onFieldSubmitted: (_) => submit(),
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          validator: (value) => Validator.validateEmail(value ?? '', context.l10n),
          decoration: InputDecoration(
            labelText: context.l10n.loginEmail,
            hintText: context.l10n.loginEmailHint,
          ),
        ),
      ],
    );
  }
}
