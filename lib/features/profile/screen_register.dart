import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/extensions.dart';
import '../../shared/layouts/scaffold_login_page.dart';
import '../../shared/providers/user.dart';
import '../../shared/repositories/repository.dart';
import '../../shared/route_names.dart';
import '../../shared/validator.dart';

class RegisterScreen extends HookConsumerWidget {
  final String? inviteCode;

  const RegisterScreen({super.key, this.inviteCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final showPassword = useState(false);
    final termsAccepted = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final termsRecognizer = useMemoized(
      () => TapGestureRecognizer()..onTap = () => context.pushNamed(RouteNames.terms),
    );
    final privacyRecognizer = useMemoized(
      () => TapGestureRecognizer()..onTap = () => context.pushNamed(RouteNames.privacy),
    );

    useEffect(
      () => () {
        termsRecognizer.dispose();
        privacyRecognizer.dispose();
      },
      [termsRecognizer, privacyRecognizer],
    );

    Future<void> register() async {
      if (isLoading.value) return;
      if (!termsAccepted.value) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms of Use and Privacy Policy to continue.')),
        );
        return;
      }
      if (formKey.currentState?.validate() ?? false) {
        isLoading.value = true;
        try {
          await ref
              .read(authProvider.notifier)
              .registerUser(
                nameController.text,
                emailController.text,
                passwordController.text,
                inviteCode: inviteCode,
              );

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
                  e is GeneralApiException ? e.message : 'Registration failed. Please try again.',
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
              Text('Register an account', style: textTheme.titleLarge),
              const SizedBox(height: 35),
              TextFormField(
                controller: nameController,
                onFieldSubmitted: (_) => register(),
                autofillHints: const [AutofillHints.name],
                validator: (value) {
                  return Validator.validateName(value ?? '');
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Chef',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                onFieldSubmitted: (_) => register(),
                autofillHints: const [AutofillHints.email],
                keyboardType: .emailAddress,
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
                onFieldSubmitted: (_) => register(),
                controller: passwordController,
                autofillHints: const [AutofillHints.newPassword],
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
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: termsAccepted.value,
                    onChanged: (v) => termsAccepted.value = v ?? false,
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'I have read and accept the '),
                          TextSpan(
                            text: 'Terms of Use',
                            style: TextStyle(color: context.colors.primary, decoration: TextDecoration.underline),
                            recognizer: termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(color: context.colors.primary, decoration: TextDecoration.underline),
                            recognizer: privacyRecognizer,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: isLoading.value ? null : register,
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Register'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => context.goNamed(
                  RouteNames.login,
                  queryParameters: {'code': inviteCode ?? ''},
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
