import 'package:flutter/material.dart';

import '../components/loading_button.dart';
import '../util/extensions.dart';
import '../util/ui_constants.dart';
import 'scaffold_login_page.dart';

/// A standard form layout for authentication and account-related screens.
class StandardAuthForm extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final List<Widget> children;
  final String submitLabel;
  final VoidCallback onSubmit;
  final bool isLoading;
  final GlobalKey<FormState> formKey;
  final Widget? secondaryButton;

  const StandardAuthForm({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    this.isLoading = false,
    required this.formKey,
    this.secondaryButton,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return ScaffoldWithSimpleLayout(
      child: AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .stretch,
            children: [
              if (eyebrow != null) ...[
                Text(eyebrow!, style: textTheme.titleSmall),
                const SizedBox(height: 4),
              ],
              Text(title, style: textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: UIConstants.paddingSmall),
                Text(subtitle!, style: textTheme.bodyMedium),
              ],
              const SizedBox(height: UIConstants.paddingLarge),
              ...children.expand((widget) => [widget, const SizedBox(height: UIConstants.paddingMedium)]),
              const SizedBox(height: UIConstants.paddingSmall),
              LoadingButton(
                isLoading: isLoading,
                onPressed: onSubmit,
                type: LoadingButtonType.elevated,
                child: Text(submitLabel),
              ),
              if (secondaryButton != null) ...[
                const SizedBox(height: 15),
                secondaryButton!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
