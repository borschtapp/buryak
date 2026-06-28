import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/unit.dart';
import '../../util/extensions.dart';
import 'unit_picker_sheet.dart';

class UnitPickerFormField extends StatelessWidget {
  const UnitPickerFormField({
    super.key,
    required this.unitsAsync,
    required this.selectedUnitId,
    required this.onSelected,
    this.onCleared,
    this.validator,
    this.labelText,
  });

  final AsyncValue<List<Unit>> unitsAsync;
  final String? selectedUnitId;
  final void Function(Unit) onSelected;
  final VoidCallback? onCleared;
  final String? Function(String?)? validator;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    final isLoading = unitsAsync.isLoading;
    final selectedUnit = unitsAsync.value?.where((u) => u.id == selectedUnitId).firstOrNull;

    Widget suffixIcon;
    if (isLoading) {
      suffixIcon = const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else if (onCleared != null && selectedUnit != null) {
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
      key: ValueKey(selectedUnit?.id),
      initialValue: selectedUnit?.name ?? '',
      decoration: InputDecoration(
        labelText: labelText ?? context.l10n.foodPriceUnit,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      onTap: () async {
        final picked = await UnitPicker.pick(context);
        if (picked != null) onSelected(picked);
      },
      validator: validator,
    );
  }
}
