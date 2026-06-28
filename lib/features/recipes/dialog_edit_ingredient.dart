import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/food_picker_sheet.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';
import '../../shared/models/recipe_ingredient.dart';

import '../../shared/providers/recipe_price.dart';
import '../../shared/repositories/recipe_repository.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'controller_recipe.dart';
import '../../shared/util/ui_constants.dart';
import '../../shared/util/validator.dart';

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
    final isSaving = useState(false);
    final isDeleting = useState(false);

    final unitsAsync = ref.watch(allUnitsProvider);

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      isSaving.value = true;
      try {
        final updated = ingredient.copyWith(
          name: nameController.text.trim(),
          amount: amountController.text.asDecimal,
          maxAmount: maxAmountController.text.asDecimal,
          description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
          unitId: selectedUnitId.value,
          foodId: selectedFood.value?.id,
        );
        await ref.read(recipeRepositoryProvider).updateIngredient(recipeId, ingredient.id, updated);
        ref.invalidate(recipeControllerProvider(recipeId));
        ref.invalidate(recipeCostEstimateProvider(recipeId));
        if (context.mounted) context.pop();
      } catch (e) {
        ref.handleException(e);
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    Future<void> delete() async {
      isDeleting.value = true;
      try {
        await ref.read(recipeRepositoryProvider).deleteIngredient(recipeId, ingredient.id);
        ref.invalidate(recipeControllerProvider(recipeId));
        ref.invalidate(recipeCostEstimateProvider(recipeId));
        if (context.mounted) context.pop();
      } catch (e) {
        ref.handleException(e);
      } finally {
        if (context.mounted) isDeleting.value = false;
      }
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
            _FoodPickerField(
              selectedFood: selectedFood.value,
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
              isLoading: isSaving.value,
              onPressed: save,
              child: Text(context.l10n.save),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            LoadingButton(
              type: LoadingButtonType.text,
              isLoading: isDeleting.value,
              onPressed: isDeleting.value ? null : delete,
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

class _FoodPickerField extends StatelessWidget {
  const _FoodPickerField({
    required this.selectedFood,
    required this.onSelected,
    required this.onCleared,
  });

  final Food? selectedFood;
  final void Function(Food) onSelected;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      key: ValueKey(selectedFood?.id),
      initialValue: selectedFood?.name ?? '',
      decoration: InputDecoration(
        labelText: context.l10n.editIngredientFood,
        border: const OutlineInputBorder(),
        suffixIcon: selectedFood != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onCleared,
                tooltip: context.l10n.close,
              )
            : const Icon(Icons.arrow_drop_down),
      ),
      onTap: () async {
        final picked = await FoodPicker.pick(context);
        if (picked != null) onSelected(picked);
      },
    );
  }
}
