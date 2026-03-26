import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/error_handler.dart';

extension ErrorHandling on WidgetRef {
  void handleException(Object exception, {String? actionLabel, VoidCallback? onAction}) {
    if (kDebugMode) {
      dev.log('$exception', name: 'error', error: exception);
    }
    read(errorHandlerProvider.notifier).handle(exception, actionLabel: actionLabel, onAction: onAction);
  }
}
