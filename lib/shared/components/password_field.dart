import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../util/extensions.dart';

/// A password field that adds a show/hide toggle to [decoration].
class PasswordField extends HookWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(),
    this.validator,
    this.autofillHints,
    this.autofocus = false,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;

  /// Label, hint, border and any error from outside the form (e.g. the server),
  /// which shows while [validator] passes. Its suffix icon is replaced by the toggle.
  final InputDecoration decoration;
  final String? Function(String value)? validator;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);

    return TextFormField(
      controller: controller,
      obscureText: !visible.value,
      autofocus: autofocus,
      autofillHints: autofillHints,
      validator: validator == null ? null : (value) => validator!(value ?? ''),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: decoration.copyWith(
        suffixIcon: IconButton(
          icon: Icon(visible.value ? Icons.visibility_off : Icons.visibility),
          tooltip: visible.value ? context.l10n.loginHidePassword : context.l10n.loginShowPassword,
          onPressed: () => visible.value = !visible.value,
        ),
      ),
    );
  }
}
