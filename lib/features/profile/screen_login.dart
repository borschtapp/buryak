import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/extensions.dart';
import '../../shared/providers/user.dart';
import '../../shared/validator.dart';
import '../../shared/route_names.dart';
import '../../shared/repositories/repository.dart';
import '../../shared/views/scaffold_login_page.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final showPassword = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    Future<void> login() async {
      if (isLoading.value) return;
      if (formKey.currentState?.validate() ?? false) {
        isLoading.value = true;
        try {
          await ref.read(authProvider.notifier).login(emailController.text, passwordController.text);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.goNamed(RouteNames.home);
          }
        } catch (e) {
          if (context.mounted) {
            isLoading.value = false;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e is GeneralApiException ? e.message : 'Login failed. Please try again.',
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
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .stretch,
          children: [
            Text('Welcome back', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            Text('Login to your account', style: textTheme.titleLarge),
            const SizedBox(height: 35),
            TextFormField(
              controller: emailController,
              onFieldSubmitted: (_) => login(),
              validator: (value) {
                return Validator.validateEmail(value ?? '');
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'abc@example.com',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: !showPassword.value,
              onFieldSubmitted: (_) => login(),
              controller: passwordController,
              validator: (value) {
                return Validator.validatePassword(value ?? '');
              },
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '********',
                suffixIcon: GestureDetector(
                  onTap: () {
                    showPassword.value = !showPassword.value;
                  },
                  child: Icon(showPassword.value ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset is not yet available.')),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading.value ? null : login,
              child: isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login now'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => context.goNamed(RouteNames.register),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
