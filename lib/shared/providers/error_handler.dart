import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ProviderObserver, ProviderObserverContext;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repository.dart';
import '../util/extensions.dart';

part 'error_handler.g.dart';

/// Localized error copy is resolved from [messageKey] where a [BuildContext] is
/// available (see `error_snackbar_listener.dart`). [text], when set, is raw
/// server-provided or field-validation text that's already user-facing and
/// must not be re-translated.
enum ErrorMessageKey {
  sessionExpired,
  noPermission,
  notFound,
  alreadyExists,
  expired,
  requestProblem,
  serverError,
  somethingWentWrong,
  connectionIssue,
}

class ErrorMessage {
  final String? text;
  final ErrorMessageKey? messageKey;
  final bool isWarning;
  final String? actionLabel;
  final VoidCallback? onAction;

  ErrorMessage({
    this.text,
    this.messageKey,
    required this.isWarning,
    this.actionLabel,
    this.onAction,
  });
}

@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  ErrorMessage? build() => null;

  void handle(Object exception, {StackTrace? stackTrace, String? actionLabel, VoidCallback? onAction}) {
    if (kDebugMode) {
      dev.log('$exception', name: 'error', error: exception, stackTrace: stackTrace);
    }
    final (text, messageKey) = resolve(exception);
    state = ErrorMessage(
      text: text,
      messageKey: messageKey,
      isWarning: _isWarning(exception),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// User-facing copy for [e]: either raw [ErrorMessage.text] or a key to localize.
  static (String?, ErrorMessageKey?) resolve(Object e) {
    if (e is FieldsApiException) {
      final text = e.fields.entries
          .map((entry) {
            final label = entry.key.split('_').map((w) => w.capitalize()).join(' ');
            return '$label: ${entry.value}';
          })
          .join('\n');
      return (text, null);
    }
    if (e is GeneralApiException) {
      // No HTTP response (timeout, socket error): the raw message is a Dart exception dump.
      if (e.statusCode == null && e.originalException != null) return (null, ErrorMessageKey.connectionIssue);
      return switch (e.statusCode) {
        401 => (null, ErrorMessageKey.sessionExpired),
        403 => (null, ErrorMessageKey.noPermission),
        404 => (null, ErrorMessageKey.notFound),
        // The server sends a generic English message for any unique-key clash.
        409 => (null, ErrorMessageKey.alreadyExists),
        // An expired invite code.
        410 => (null, ErrorMessageKey.expired),
        422 => e.message.isNotEmpty ? (e.message, null) : (null, ErrorMessageKey.requestProblem),
        500 => (null, ErrorMessageKey.serverError),
        _ => e.message.isNotEmpty ? (e.message, null) : (null, ErrorMessageKey.somethingWentWrong),
      };
    }
    return (null, ErrorMessageKey.connectionIssue);
  }

  static bool _isWarning(Object e) {
    if (e is GeneralApiException) {
      final code = e.statusCode;
      if (code == 401 || code == 403) return false;
      if (code != null && code >= 500) return false;
    }
    return true;
  }
}

/// A failure that the form which started it shows next to the field at fault,
/// so [MutationErrorReporter] leaves it out of the global error snackbar.
abstract interface class InlineError implements Exception {}

/// Reports every failed [Mutation] through [ErrorHandler], so call sites don't
/// catch-and-report themselves; an [InlineError] is left to its form. Because it observes the container rather than
/// a widget, a failure is still shown after the sheet that started the
/// mutation has been dismissed.
final class MutationErrorReporter extends ProviderObserver {
  @override
  void mutationError(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
    Object error,
    StackTrace stackTrace,
  ) {
    if (error is InlineError) return;
    context.container.read(errorHandlerProvider.notifier).handle(error, stackTrace: stackTrace);
  }
}
