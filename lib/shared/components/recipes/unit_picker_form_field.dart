import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/unit.dart';
import '../../util/extensions.dart';
import '../picker_form_field.dart';
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
    final selectedUnit = unitsAsync.value?.where((u) => u.id == selectedUnitId).firstOrNull;
    return PickerFormField<Unit>(
      selectionKey: selectedUnit?.id,
      selectionLabel: selectedUnit?.name,
      labelText: labelText ?? context.l10n.foodPriceUnit,
      isLoading: unitsAsync.isLoading,
      pick: UnitPicker.pick,
      onSelected: onSelected,
      onCleared: onCleared,
      validator: validator,
    );
  }
}
