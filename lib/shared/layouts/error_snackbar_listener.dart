import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/error_handler.dart';
import '../util/extensions.dart';

class ErrorSnackBarListener extends ConsumerWidget {
  final Widget child;

  const ErrorSnackBarListener({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ErrorMessage?>(errorHandlerProvider, (_, message) {
      if (message == null) return;

      final text = message.messageKey != null ? _resolveKey(context, message.messageKey!) : message.text ?? '';

      if (kDebugMode) {
        dev.log(text, name: 'error');
      }

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

String _resolveKey(BuildContext context, ErrorMessageKey key) => switch (key) {
  ErrorMessageKey.sessionExpired => context.l10n.errorSessionExpired,
  ErrorMessageKey.noPermission => context.l10n.errorNoPermission,
  ErrorMessageKey.notFound => context.l10n.errorNotFound,
  ErrorMessageKey.requestProblem => context.l10n.errorRequestProblem,
  ErrorMessageKey.serverError => context.l10n.errorServerError,
  ErrorMessageKey.somethingWentWrong => context.l10n.errorSomethingWentWrong,
  ErrorMessageKey.connectionIssue => context.l10n.errorConnectionIssue,
};
