import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';

import '../../l10n/app_localizations.dart';
import '../providers/error_handler.dart';
import 'extensions.dart';

extension ErrorHandling on WidgetRef {
  void handleException(Object exception, {String? actionLabel, VoidCallback? onAction}) {
    read(errorHandlerProvider.notifier).handle(exception, actionLabel: actionLabel, onAction: onAction);
  }
}

extension ErrorMessageKeyL10n on ErrorMessageKey {
  String localized(AppLocalizations l10n) => switch (this) {
    .sessionExpired => l10n.errorSessionExpired,
    .noPermission => l10n.errorNoPermission,
    .notFound => l10n.errorNotFound,
    .alreadyExists => l10n.errorAlreadyExists,
    .expired => l10n.errorExpired,
    .requestProblem => l10n.errorRequestProblem,
    .serverError => l10n.errorServerError,
    .somethingWentWrong => l10n.errorSomethingWentWrong,
    .connectionIssue => l10n.errorConnectionIssue,
  };
}

extension ErrorDescription on BuildContext {
  /// The text the error snackbar would show for [error], for showing it inline instead.
  String errorMessage(Object error) {
    final (text, key) = ErrorHandler.resolve(error);
    return key?.localized(l10n) ?? text ?? '';
  }
}

extension TryRunMutation<T> on Mutation<T> {
  /// [Mutation.run] for callers that only need to know whether it worked.
  ///
  /// Resolves to `false` instead of throwing: the failure has already been
  /// reported by [MutationErrorReporter]. Callers still check
  /// `context.mounted` before touching the UI.
  Future<bool> tryRun(MutationTarget target, Future<T> Function(MutationTransaction tsx) cb) =>
      run(target, cb).then((_) => true, onError: (Object _) => false);
}
