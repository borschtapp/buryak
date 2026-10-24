import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/error_handler.dart';
import '../util/error_extensions.dart';
import '../util/extensions.dart';

class ErrorSnackBarListener extends ConsumerWidget {
  final Widget child;

  const ErrorSnackBarListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ErrorMessage?>(errorHandlerProvider, (_, message) {
      if (message == null) return;

      final text = message.messageKey?.localized(context.l10n) ?? message.text ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: message.isWarning ? context.colors.tertiaryContainer : context.colors.errorContainer,
          action: message.actionLabel != null
              ? SnackBarAction(
                  label: message.actionLabel!,
                  onPressed: message.onAction ?? () {},
                )
              : null,
        ),
      );
    });

    return child;
  }
}
