import 'package:flutter/material.dart';

import '../util/extensions.dart';
import 'loading_indicator.dart';

/// Read-only form field that opens a picker on tap and shows the selection's
/// label. The suffix is a spinner while [isLoading], a clear button when there
/// is a selection and [onCleared] is set, and a dropdown arrow otherwise.
class PickerFormField<T> extends StatelessWidget {
  const PickerFormField({
    super.key,
    required this.selectionKey,
    required this.selectionLabel,
    required this.labelText,
    required this.pick,
    required this.onSelected,
    this.onCleared,
    this.validator,
    this.isLoading = false,
  });

  /// Identifies the current selection; the field resets its text when it or
  /// [selectionLabel] changes.
  final Object? selectionKey;

  /// Label of the current selection, or `null` when nothing is selected.
  final String? selectionLabel;

  final String labelText;
  final Future<T?> Function(BuildContext context) pick;
  final void Function(T value) onSelected;
  final VoidCallback? onCleared;
  final String? Function(String?)? validator;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final Widget suffixIcon;
    if (isLoading) {
      suffixIcon = const Padding(padding: EdgeInsets.all(12), child: LoadingIndicator());
    } else if (onCleared != null && selectionLabel != null) {
      suffixIcon = IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: onCleared,
        tooltip: context.l10n.close,
      );
    } else {
      suffixIcon = const Icon(Icons.arrow_drop_down);
    }

    return TextFormField(
      readOnly: true,
      // Also keyed by the label, so renaming the selected item refreshes the text.
      key: ValueKey((selectionKey, selectionLabel)),
      initialValue: selectionLabel ?? '',
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      onTap: () async {
        final picked = await pick(context);
        if (picked != null) onSelected(picked);
      },
      validator: validator,
    );
  }
}
