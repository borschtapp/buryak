import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_indicator.dart';
import '../../shared/layouts/scaffold_login_page.dart';
import '../../shared/providers/server_url.dart';
import '../../shared/providers/user.dart';
import '../../shared/repositories/repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';
import 'dialog_server_url.dart';

class LoginScreen extends HookConsumerWidget {
  final String? inviteCode;

  const LoginScreen({super.key, this.inviteCode});

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
            if (inviteCode != null && inviteCode!.isNotEmpty) {
              context.goNamed(RouteNames.profile, queryParameters: {'joinCode': inviteCode});
            } else {
              context.goNamed(RouteNames.home);
            }
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
    final serverUrl = ref.watch(serverUrlProvider);

    return ScaffoldWithSimpleLayout(
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .stretch,
            children: [
              Text('Welcome back', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              Text('Login to your account', style: textTheme.titleLarge),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => const ServerUrlDialog(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 16, color: context.colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          serverUrl,
                          style: textTheme.bodySmall?.copyWith(color: context.colors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.edit, size: 16, color: context.colors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                onFieldSubmitted: (_) => login(),
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
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
                autofillHints: const [AutofillHints.password],
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
                  onPressed: () => context.goNamed(RouteNames.forgotPassword),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading.value ? null : login,
                child: isLoading.value ? const LoadingIndicator() : const Text('Login now'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => context.goNamed(
                  RouteNames.register,
                  queryParameters: inviteCode != null ? {'code': inviteCode!} : const {},
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
