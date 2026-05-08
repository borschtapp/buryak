import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/layouts/standard_auth_form.dart';
import '../../shared/providers/user.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';

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
            context.goNamed(RouteNames.feed);
          }
        } catch (e) {
          ref.handleException(e);
          if (context.mounted) {
            isLoading.value = false;
          }
        }
      }
    }

    final textTheme = context.textTheme;

    return StandardAuthForm(
      title: 'Register an account',
      formKey: formKey,
      isLoading: isLoading.value,
      onSubmit: register,
      submitLabel: 'Register',
      secondaryButton: TextButton(
        onPressed: () => context.goNamed(
          RouteNames.login,
          queryParameters: {'code': inviteCode ?? ''},
        ),
        child: const Text('Login'),
      ),
      children: [
        TextFormField(
          controller: nameController,
          onFieldSubmitted: (_) => register(),
          autofillHints: const [AutofillHints.name],
          validator: (value) => Validator.validateName(value ?? ''),
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Chef',
          ),
        ),
        TextFormField(
          controller: emailController,
          onFieldSubmitted: (_) => register(),
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          validator: (value) => Validator.validateEmail(value ?? ''),
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'abc@example.com',
          ),
        ),
        TextFormField(
          obscureText: !showPassword.value,
          onFieldSubmitted: (_) => register(),
          controller: passwordController,
          autofillHints: const [AutofillHints.newPassword],
          validator: (value) => Validator.validatePassword(value ?? ''),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '********',
            suffixIcon: GestureDetector(
              onTap: () => showPassword.value = !showPassword.value,
              child: Icon(showPassword.value ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
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
      ],
    );
  }
}
