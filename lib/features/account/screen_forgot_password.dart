import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/layouts/standard_auth_form.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
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
              const SnackBar(content: Text('If an account exists, a reset link has been sent.')),
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
      title: 'Forgot Password',
      subtitle: 'Enter your email address to receive a password reset link.',
      formKey: formKey,
      isLoading: isLoading.value,
      onSubmit: submit,
      submitLabel: 'Send Link',
      secondaryButton: TextButton(
        onPressed: () => context.goNamed(RouteNames.login),
        child: const Text('Back to Login'),
      ),
      children: [
        TextFormField(
          controller: emailController,
          onFieldSubmitted: (_) => submit(),
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          validator: (value) => Validator.validateEmail(value ?? ''),
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'abc@example.com',
          ),
        ),
      ],
    );
  }
}
