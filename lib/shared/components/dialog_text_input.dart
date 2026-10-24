import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';
import 'loading_button.dart';

/// A reusable dialog widget for collecting single text input from users.
///
/// Submitting runs [onSubmit] as [mutation]; the dialog shows its pending
/// state, closes on success and then calls [onSuccess] with the result. On
/// failure it stays open so the input can be corrected, and
/// `MutationErrorReporter` reports the error.
class TextInputDialog<T> extends HookConsumerWidget {
  final String title;
  final String hintText;
  final String submitLabel;
  final String? labelText;
  final String? helperText;

  /// Optional inline validation function.
  /// Returns an error message if validation fails, null if valid.
  final String? Function(String)? validator;
  final String? initialText;

  final Mutation<T> mutation;

  /// The write, given the trimmed input; run it through [MutationTransaction.get].
  final Future<T> Function(MutationTransaction tsx, String value) onSubmit;

  /// Called after the dialog has closed, e.g. to show a snackbar or navigate
  /// from the caller's (still mounted) context.
  final void Function(T result)? onSuccess;

  const TextInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.submitLabel,
    this.labelText,
    this.helperText,
    this.validator,
    this.initialText,
    required this.mutation,
    required this.onSubmit,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: initialText);
    final validationError = useState<String?>(null);
    final isLoading = ref.watch(mutation).isPending;

    Future<void> submit() async {
      final value = controller.text.trim();

      final error = validator?.call(value);
      validationError.value = error;
      if (error != null) return;

      final T result;
      try {
        result = await mutation.run(ref, (tsx) => onSubmit(tsx, value));
      } on Object {
        return; // Already reported by MutationErrorReporter.
      }
      if (!context.mounted) return;
      context.pop();
      onSuccess?.call(result);
    }

    return Dialog(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            TextField(
              controller: controller,
              autofocus: true,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                helperText: helperText,
                errorText: validationError.value,
              ),
              onSubmitted: isLoading ? null : (_) => submit(),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  child: LoadingButton(
                    isLoading: isLoading,
                    onPressed: submit,
                    child: Text(submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
