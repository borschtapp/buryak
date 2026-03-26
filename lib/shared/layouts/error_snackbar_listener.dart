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

      if (kDebugMode) {
        dev.log(message.text, name: 'error');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.text),
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
