import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/repository.dart';
import '../util/extensions.dart';

part 'error_handler.g.dart';

class ErrorMessage {
  final String text;
  final bool isWarning;
  final String? actionLabel;
  final VoidCallback? onAction;

  ErrorMessage({
    required this.text,
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
    state = ErrorMessage(
      text: _toMessage(exception),
      isWarning: _isWarning(exception),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static String _toMessage(Object e) {
    if (e is FieldsApiException) {
      return e.fields.entries
          .map((entry) {
            final label = entry.key.split('_').map((w) => w.capitalize()).join(' ');
            return '$label: ${entry.value}';
          })
          .join('\n');
    }
    if (e is GeneralApiException) {
      return switch (e.statusCode) {
        401 => 'Your session expired. Please log in again.',
        403 => 'You don\'t have permission to do this.',
        404 => 'The requested item was not found.',
        422 => 'There was a problem with your request. Please check and try again.',
        500 => 'Server error. Please try again later.',
        _ => e.message.isNotEmpty ? e.message : 'Something went wrong. Please try again.',
      };
    }
    return 'Connection issue. Please check your internet.';
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
