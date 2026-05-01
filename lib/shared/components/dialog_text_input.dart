import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../util/error_extensions.dart';
import '../util/extensions.dart';

/// A reusable dialog widget for collecting single text input from users.
///
/// Handles loading state, optional validation, and error display via SnackBar.
/// Does not auto-pop on success — [onSubmit] is responsible for navigation.
class TextInputDialog extends HookConsumerWidget {
  final String title;
  final String hintText;
  final String submitLabel;
  final String? labelText;
  final String? helperText;

  /// Optional inline validation function.
  /// Returns an error message if validation fails, null if valid.
  final String? Function(String)? validator;

  /// Callback invoked when user submits.
  /// Responsible for navigation (pop or replace).
  final Future<void> Function(String value, BuildContext context) onSubmit;

  const TextInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.submitLabel,
    this.labelText,
    this.helperText,
    this.validator,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isLoading = useState(false);
    final validationError = useState<String?>(null);

    return Dialog(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              enabled: !isLoading.value,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                helperText: helperText,
                errorText: validationError.value,
              ),
              onSubmitted: isLoading.value ? null : (_) => _handleSubmit(context, ref, controller, isLoading, validationError),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading.value ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading.value ? null : () => _handleSubmit(context, ref, controller, isLoading, validationError),
                    child: isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> validationError,
  ) async {
    final value = controller.text.trim();

    // Run optional validator
    if (validator != null) {
      final error = validator!(value);
      validationError.value = error;
      if (error != null) return;
    }

    isLoading.value = true;
    try {
      await onSubmit(value, context);
    } catch (e) {
      ref.handleException(e);
    } finally {
      if (context.mounted) {
        isLoading.value = false;
      }
    }
  }
}
