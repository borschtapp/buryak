import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';
import '../../shared/models/food_price.dart';
import '../../shared/models/food_unit_conversion.dart';
import '../../shared/models/unit.dart';
import '../../shared/providers/food_catalog.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/util/validator.dart';

class FoodConversionBottomSheet extends HookConsumerWidget {
  const FoodConversionBottomSheet({
    super.key,
    required this.food,
    required this.unitId,
    required this.unitName,
    this.prices = const [],
    this.existing,
    this.targetUnitId,
  });

  final Food food;
  final String unitId;
  final String unitName;
  final List<FoodPrice> prices;
  final FoodUnitConversion? existing;

  /// Target to preselect instead of [existing]'s, whose amount is kept only for the same target.
  final String? targetUnitId;

  static void show(
    BuildContext context, {
    required Food food,
    required String unitId,
    required String unitName,
    List<FoodPrice> prices = const [],
    FoodUnitConversion? existing,
  }) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => FoodConversionBottomSheet(
        food: food,
        unitId: unitId,
        unitName: unitName,
        prices: prices,
        existing: existing,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final initialTargetUnitId = targetUnitId ?? existing?.targetUnitId;
    // An amount only holds for the unit it was given in.
    final amountController = useTextEditingController(
      text: existing?.targetUnitId == initialTargetUnitId ? existing?.targetAmount.formatAmount : null,
    );
    final isSaving = ref.watch(saveConversionMutation).isPending;
    final unitsAsync = ref.watch(allUnitsProvider);
    final unitsById = (unitsAsync.value ?? const <Unit>[]).byId;
    final source = unitsById[unitId];
    bool isTarget(Unit unit) => source != null ? unit.isConversionTargetFor(source) : unit.isMeasurable && unit.id != unitId;

    final pickedTargetUnitId = useState<String?>(initialTargetUnitId);
    // Suggest the food's own units, skipping any the server would reject (e.g. the
    // default unit is often the source unit itself).
    final selectedTargetUnitId =
        pickedTargetUnitId.value ??
        [food.defaultUnitId, ...prices.map((p) => p.unitId)].map((id) => unitsById[id]).nonNulls.where(isTarget).firstOrNull?.id;

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      if (selectedTargetUnitId == null) return;

      final saved = await saveConversionMutation.tryRun(
        ref,
        (tsx) => tsx
            .get(foodCatalogProvider)
            .saveConversion(
              food.id,
              existingId: existing?.id,
              unitId: unitId,
              targetAmount: amountController.text.asDecimal!,
              targetUnitId: selectedTargetUnitId,
            ),
      );
      if (saved && context.mounted) context.pop();
    }

    return StandardBottomSheet(
      title: context.l10n.foodConversionTitle,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.foodConversionFormHint(unitName, food.name),
              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: context.l10n.foodPriceAmount,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.l10n.validatorFieldRequired;
                      return Validator.positiveNumber(v, context.l10n);
                    },
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  flex: 3,
                  child: UnitPickerFormField(
                    unitsAsync: unitsAsync,
                    selectedUnitId: selectedTargetUnitId,
                    onSelected: (u) => pickedTargetUnitId.value = u.id,
                    labelText: context.l10n.foodConversionTargetUnit,
                    where: isTarget,
                    validator: (_) => selectedTargetUnitId == null ? context.l10n.validatorFieldRequired : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: context.colors.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    context.l10n.foodConversionImpactNote(food.name),
                    style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            LoadingButton(
              isLoading: isSaving,
              onPressed: submit,
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
