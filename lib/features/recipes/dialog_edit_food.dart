import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/recipes/food_merge.dart';
import '../../shared/components/recipes/unit_picker_form_field.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food.dart';
import '../../shared/providers/food_catalog.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

class EditFoodBottomSheet extends HookConsumerWidget {
  const EditFoodBottomSheet({
    super.key,
    required this.food,
  });

  final Food food;

  static void show(
    BuildContext context, {
    required Food food,
  }) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => EditFoodBottomSheet(food: food),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: food.name);
    final selectedUnitId = useState<String?>(food.defaultUnitId);
    final isPantry = useState(food.pantry ?? false);
    final isSaving = ref.watch(updateFoodMutation).isPending;
    final isMerging = ref.watch(mergeFoodsMutation).isPending;

    final unitsAsync = ref.watch(allUnitsProvider);

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final newName = nameController.text.trim();
      final unitChanged = selectedUnitId.value != food.defaultUnitId;
      final saved = await updateFoodMutation.tryRun(
        ref,
        (tsx) => tsx
            .get(foodCatalogProvider)
            .updateFood(
              food.id,
              name: newName != food.name ? newName : null,
              defaultUnitId: unitChanged ? selectedUnitId.value : null,
              clearDefaultUnit: unitChanged && selectedUnitId.value == null,
              pantry: isPantry.value != (food.pantry ?? false) ? isPantry.value : null,
            ),
      );
      if (saved && context.mounted) context.pop();
    }

    Future<void> merge() async {
      final merged = await runFoodMergeFlow(context, ref, source: food);
      if (merged && context.mounted) context.pop();
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
              isLoading: isSaving,
              onPressed: save,
              child: Text(context.l10n.save),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            LoadingButton(
              type: LoadingButtonType.text,
              isLoading: isMerging,
              onPressed: (isSaving || isMerging) ? null : merge,
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
