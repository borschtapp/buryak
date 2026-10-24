import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/picker_form_field.dart';
import '../../shared/components/recipes/food_picker_sheet.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/util/validator.dart';
import 'controller_recipe.dart';

class EditIngredientBottomSheet extends HookConsumerWidget {
  const EditIngredientBottomSheet({
    super.key,
    required this.recipeId,
    required this.ingredient,
  });

  final String recipeId;
  final RecipeIngredient ingredient;

  static void show(
    BuildContext context, {
    required String recipeId,
    required RecipeIngredient ingredient,
  }) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => EditIngredientBottomSheet(recipeId: recipeId, ingredient: ingredient),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: ingredient.displayName);
    final amountController = useTextEditingController(
      text: (ingredient.amount == null || ingredient.amount == 0) ? '' : ingredient.amount!.formatAmount,
    );
    final maxAmountController = useTextEditingController(text: ingredient.maxAmount.formatAmount);
    final descriptionController = useTextEditingController(text: ingredient.description ?? '');
    final selectedUnitId = useState<String?>(ingredient.unitId ?? ingredient.unit?.id);
    final selectedFood = useState<Food?>(ingredient.food);
    final isSaving = ref.watch(updateIngredientMutation).isPending;
    final isDeleting = ref.watch(deleteIngredientMutation).isPending;

    final unitsAsync = ref.watch(allUnitsProvider);

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final updated = ingredient.copyWith(
        name: nameController.text.trim(),
        amount: amountController.text.asDecimal,
        maxAmount: maxAmountController.text.asDecimal,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        unitId: selectedUnitId.value,
        foodId: selectedFood.value?.id,
      );
      final saved = await updateIngredientMutation.tryRun(
        ref,
        (tsx) => tsx.get(recipeControllerProvider(recipeId).notifier).updateIngredient(ingredient.id, updated),
      );
      if (saved && context.mounted) context.pop();
    }

    Future<void> delete() async {
      final deleted = await deleteIngredientMutation.tryRun(
        ref,
        (tsx) => tsx.get(recipeControllerProvider(recipeId).notifier).deleteIngredient(ingredient.id),
      );
      if (deleted && context.mounted) context.pop();
    }

    return StandardBottomSheet(
      title: context.l10n.editIngredientTitle,
      maxHeightFraction: 0.8,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.editIngredientName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.validatorFieldRequired : null,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            PickerFormField<Food>(
              selectionKey: selectedFood.value?.id,
              selectionLabel: selectedFood.value?.name,
              labelText: context.l10n.editIngredientFood,
              pick: FoodPicker.pick,
              onSelected: (f) => selectedFood.value = f,
              onCleared: () => selectedFood.value = null,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
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
                    validator: (v) => Validator.optionalPositiveNumber(v ?? '', context.l10n),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: maxAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: context.l10n.editIngredientMaxAmount,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => Validator.optionalPositiveNumber(v ?? '', context.l10n),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  flex: 3,
                  child: UnitPickerFormField(
                    unitsAsync: unitsAsync,
                    selectedUnitId: selectedUnitId.value,
                    onSelected: (u) => selectedUnitId.value = u.id,
                    onCleared: () => selectedUnitId.value = null,
                    labelText: context.l10n.foodPriceUnit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            TextFormField(
              controller: descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: context.l10n.editIngredientNotes,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            LoadingButton(
              isLoading: isSaving,
              onPressed: save,
              child: Text(context.l10n.save),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            LoadingButton(
              type: LoadingButtonType.text,
              isLoading: isDeleting,
              onPressed: isDeleting ? null : delete,
              spinnerSize: 16,
              icon: const Icon(Icons.delete_outline),
              style: TextButton.styleFrom(foregroundColor: context.colors.error),
              child: Text(context.l10n.delete),
            ),
          ],
        ),
      ),
    );
  }
}
