import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/extensions.dart';
import '../../shared/validator.dart';
import '../../shared/route_names.dart';
import '../../shared/repositories/repository.dart';
import '../../shared/repositories/user_repository.dart';
import '../../shared/views/scaffold_login_page.dart';

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
          await ref.read(userRepositoryProvider).resetPassword(token, passwordController.text);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully.')),
            );
            context.goNamed(RouteNames.login);
          }
        } catch (e) {
          if (context.mounted) {
            isLoading.value = false;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e is GeneralApiException ? e.message : 'Reset failed. Please try again.',
                  style: TextStyle(color: context.colors.onErrorContainer),
                ),
                backgroundColor: context.colors.errorContainer,
              ),
            );
          }
        }
      }
    }

    final textTheme = context.textTheme;

    return ScaffoldWithSimpleLayout(
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .stretch,
            children: [
              Text('Reset Password', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Enter your new password below.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                obscureText: !showPassword.value,
                onFieldSubmitted: (_) => submit(),
                controller: passwordController,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  return Validator.validatePassword(value ?? '');
                },
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: '********',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      showPassword.value = !showPassword.value;
                    },
                    child: Icon(showPassword.value ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading.value ? null : submit,
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reset Password'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => context.goNamed(RouteNames.login),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
