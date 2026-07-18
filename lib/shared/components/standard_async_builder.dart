import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/extensions.dart';
import 'error_state.dart';

/// A standard builder for [AsyncValue] that provides consistent loading and error states.
class StandardAsyncBuilder<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stack)? error;
  final Widget Function()? loading;
  final VoidCallback? onRetry;
  final String? errorTitle;

  const StandardAsyncBuilder({
    super.key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
    this.onRetry,
    this.errorTitle,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading ?? () => const Center(child: CircularProgressIndicator()),
      error:
          error ??
          (err, stack) => ErrorState(
            title: errorTitle ?? context.l10n.errorSomethingWentWrong,
            message: err.toString(),
            onRetry: onRetry,
          ),
    );
  }
}
