import 'dart:ui';

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

  void handle(Object exception, {String? actionLabel, VoidCallback? onAction}) {
    final (text, messageKey) = _resolve(exception);
    state = ErrorMessage(
      text: text,
      messageKey: messageKey,
      isWarning: _isWarning(exception),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static (String?, ErrorMessageKey?) _resolve(Object e) {
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
      return switch (e.statusCode) {
        401 => (null, ErrorMessageKey.sessionExpired),
        403 => (null, ErrorMessageKey.noPermission),
        404 => (null, ErrorMessageKey.notFound),
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
