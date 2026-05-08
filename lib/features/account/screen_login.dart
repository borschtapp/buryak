import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/icon_label.dart';
import '../../shared/layouts/standard_auth_form.dart';
import '../../shared/providers/server_url.dart';
import '../../shared/providers/user.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/validator.dart';
import 'dialog_server_url.dart';

const _devEmail = String.fromEnvironment('DEV_EMAIL');
const _devPassword = String.fromEnvironment('DEV_PASSWORD');

class LoginScreen extends HookConsumerWidget {
  final String? inviteCode;

  const LoginScreen({super.key, this.inviteCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final showPassword = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController(text: kDebugMode ? _devEmail : '');
    final passwordController = useTextEditingController(text: kDebugMode ? _devPassword : '');

    Future<void> login() async {
      if (isLoading.value) return;
      if (formKey.currentState?.validate() ?? false) {
        isLoading.value = true;
        try {
          await ref.read(authProvider.notifier).login(emailController.text, passwordController.text);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (inviteCode != null && inviteCode!.isNotEmpty) {
              context.goNamed(RouteNames.account, queryParameters: {'joinCode': inviteCode});
            } else {
              context.goNamed(RouteNames.feed);
            }
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
    final serverUrl = ref.watch(serverUrlProvider);

    return StandardAuthForm(
      eyebrow: 'Welcome back',
      title: 'Login to your account',
      formKey: formKey,
      isLoading: isLoading.value,
      onSubmit: login,
      submitLabel: 'Login now',
      secondaryButton: TextButton(
        onPressed: () => context.goNamed(
          RouteNames.register,
          queryParameters: inviteCode != null ? {'code': inviteCode!} : const {},
        ),
        child: const Text('Register'),
      ),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showServerUrlDialog(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: IconLabel(
                    icon: Icons.link,
                    label: serverUrl,
                    color: context.colors.primary,
                    iconSize: 16,
                    textStyle: textTheme.bodySmall,
                  ),
                ),
                Icon(Icons.edit, size: 16, color: context.colors.primary),
              ],
            ),
          ),
        ),
        TextFormField(
          controller: emailController,
          onFieldSubmitted: (_) => login(),
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
          onFieldSubmitted: (_) => login(),
          controller: passwordController,
          autofillHints: const [AutofillHints.password],
          validator: (value) => Validator.validatePassword(value ?? ''),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '********',
            suffixIcon: IconButton(
              icon: Icon(showPassword.value ? Icons.visibility_off : Icons.visibility),
              tooltip: showPassword.value ? 'Hide password' : 'Show password',
              onPressed: () => showPassword.value = !showPassword.value,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.goNamed(RouteNames.forgotPassword),
            child: const Text('Forgot password?'),
          ),
        ),
      ],
    );
  }
}
