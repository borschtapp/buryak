import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/ui_constants.dart';
import 'loading_button.dart';
import 'standard_bottom_sheet.dart';

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

  /// Stops input at this many characters, without showing a counter.
  final int? maxLength;

  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

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
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    required this.mutation,
    required this.onSubmit,
    this.onSuccess,
  });

  /// Opens this dialog as an adaptive modal: a bottom sheet on mobile, a
  /// centered dialog on tablet/desktop.
  Future<T?> show(BuildContext context) => showAppBottomSheet<T>(context: context, builder: (_) => this);

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

    return StandardBottomSheet(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            enabled: !isLoading,
            textCapitalization: textCapitalization,
            autofillHints: autofillHints,
            inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              helperText: helperText,
              errorText: validationError.value,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: isLoading ? null : (_) => submit(),
          ),
          const SizedBox(height: UIConstants.paddingLarge),
          LoadingButton(
            isLoading: isLoading,
            onPressed: submit,
            child: Text(submitLabel),
          ),
        ],
      ),
    );
  }
}
