import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/food_merge.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';

import '../../shared/providers/recipe_price.dart';
import '../../shared/repositories/food_repository.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'controller_recipe.dart';

class EditFoodBottomSheet extends HookConsumerWidget {
  const EditFoodBottomSheet({
    super.key,
    required this.food,
    required this.recipeId,
  });

  final Food food;
  final String recipeId;

  static void show(
    BuildContext context, {
    required Food food,
    required String recipeId,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditFoodBottomSheet(food: food, recipeId: recipeId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: food.name);
    final selectedUnitId = useState<String?>(food.defaultUnitId);
    final isPantry = useState(food.pantry ?? false);
    final isSaving = useState(false);
    final isMerging = useState(false);

    final unitsAsync = ref.watch(allUnitsProvider);

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      isSaving.value = true;
      try {
        final newName = nameController.text.trim();
        await ref
            .read(foodRepositoryProvider)
            .update(
              food.id,
              name: newName != food.name ? newName : null,
              defaultUnitId: selectedUnitId.value,
              pantry: isPantry.value != (food.pantry ?? false) ? isPantry.value : null,
            );
        ref.invalidate(recipeControllerProvider);
        ref.invalidate(recipeCostEstimateProvider);
        if (context.mounted) context.pop();
      } catch (e) {
        ref.handleException(e);
      } finally {
        if (context.mounted) isSaving.value = false;
      }
    }

    Future<void> merge() async {
      isMerging.value = true;
      try {
        final merged = await runFoodMergeFlow(context, ref, source: food);
        if (merged) {
          ref.invalidate(recipeControllerProvider);
          if (context.mounted) context.pop();
        }
      } finally {
        if (context.mounted) isMerging.value = false;
      }
    }

    return StandardBottomSheet(
      title: context.l10n.editFoodTitle,
      maxHeightFraction: 0.7,
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
            UnitPickerFormField(
              unitsAsync: unitsAsync,
              selectedUnitId: selectedUnitId.value,
              onSelected: (u) => selectedUnitId.value = u.id,
              onCleared: () => selectedUnitId.value = null,
              labelText: context.l10n.editFoodDefaultUnit,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            SwitchListTile.adaptive(
              value: isPantry.value,
              onChanged: (v) => isPantry.value = v,
              title: Text(context.l10n.editFoodPantry),
              subtitle: Text(context.l10n.editFoodPantryHint),
              contentPadding: EdgeInsets.zero,
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
              isLoading: isMerging.value,
              onPressed: (isSaving.value || isMerging.value) ? null : merge,
              spinnerSize: 16,
              icon: const Icon(Icons.merge_outlined),
              child: Text(context.l10n.editFoodMerge),
            ),
          ],
        ),
      ),
    );
  }
}
