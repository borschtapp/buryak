import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/layouts/standard_auth_form.dart';
import '../../shared/repositories/auth_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/validator.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final showPassword = useState(false);
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
              const SnackBar(content: Text('Password updated successfully.')),
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
      title: 'Reset Password',
      subtitle: 'Enter your new password below.',
      formKey: formKey,
      isLoading: isLoading.value,
      onSubmit: submit,
      submitLabel: 'Reset Password',
      secondaryButton: TextButton(
        onPressed: () => context.goNamed(RouteNames.login),
        child: const Text('Back to Login'),
      ),
      children: [
        TextFormField(
          obscureText: !showPassword.value,
          onFieldSubmitted: (_) => submit(),
          controller: passwordController,
          autofillHints: const [AutofillHints.newPassword],
          validator: (value) => Validator.validatePassword(value ?? ''),
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: '********',
            suffixIcon: GestureDetector(
              onTap: () => showPassword.value = !showPassword.value,
              child: Icon(showPassword.value ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
      ],
    );
  }
}
