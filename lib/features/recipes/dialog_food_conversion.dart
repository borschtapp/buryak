import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';
import '../../shared/models/food_price.dart';
import '../../shared/models/food_unit_conversion.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/repositories/food_repository.dart';
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
  });

  final Food food;
  final String unitId;
  final String unitName;
  final List<FoodPrice> prices;
  final FoodUnitConversion? existing;

  static void show(
    BuildContext context, {
    required Food food,
    required String unitId,
    required String unitName,
    List<FoodPrice> prices = const [],
    FoodUnitConversion? existing,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
    final amountController = useTextEditingController(
      text: existing?.targetAmount.formatAmount ?? '',
    );
    final isSaving = useState(false);
    final unitsAsync = ref.watch(allUnitsProvider);
    final selectedTargetUnitId = useState<String?>(
      existing?.targetUnitId ?? food.defaultUnitId ?? prices.firstOrNull?.unitId,
    );

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final targetUnitId = selectedTargetUnitId.value;
      if (targetUnitId == null) return;

      isSaving.value = true;
      try {
        final repo = ref.read(foodRepositoryProvider);
        if (existing != null) {
          await repo.updateConversion(
            food.id,
            existing!.id,
            unitId,
            amountController.text.asDecimal!,
            targetUnitId,
          );
        } else {
          await repo.createConversion(
            food.id,
            unitId,
            amountController.text.asDecimal!,
            targetUnitId,
          );
        }
        ref.invalidate(foodConversionsProvider(food.id));
        if (context.mounted) Navigator.of(context).pop();
      } catch (e) {
        ref.handleException(e);
      } finally {
        if (context.mounted) isSaving.value = false;
      }
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
                    selectedUnitId: selectedTargetUnitId.value,
                    onSelected: (u) => selectedTargetUnitId.value = u.id,
                    labelText: context.l10n.foodConversionTargetUnit,
                    validator: (_) => selectedTargetUnitId.value == null ? context.l10n.validatorFieldRequired : null,
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
              isLoading: isSaving.value,
              onPressed: submit,
              child: Text(context.l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
