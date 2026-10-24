import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/unit.dart';
import '../../providers/food_catalog.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import '../loading_button.dart';
import '../standard_bottom_sheet.dart';
import 'unit_merge.dart';

/// Contextual unit curation: rename a unit, or merge it into another.
///
/// Both actions are household-global; [FoodCatalog] refreshes every cache that
/// shows units (pickers, recipes, prices, shopping list) on success.
class EditUnitBottomSheet extends HookConsumerWidget {
  const EditUnitBottomSheet({super.key, required this.unit});

  final Unit unit;

  static void show(BuildContext context, {required Unit unit}) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => EditUnitBottomSheet(unit: unit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: unit.name);
    final isSaving = ref.watch(renameUnitMutation).isPending;
    final isMerging = ref.watch(mergeUnitsMutation).isPending;

    Future<void> save() async {
      final newName = nameController.text.trim();
      if (newName.isEmpty || newName == unit.name) {
        context.pop();
        return;
      }
      final saved = await renameUnitMutation.tryRun(
        ref,
        (tsx) => tsx.get(foodCatalogProvider).renameUnit(unit.id, newName),
      );
      if (saved && context.mounted) context.pop();
    }

    Future<void> merge() async {
      final merged = await runUnitMergeFlow(context, ref, source: unit);
      if (merged && context.mounted) context.pop();
    }

    return StandardBottomSheet(
      title: context.l10n.editUnitTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.none,
            decoration: InputDecoration(
              labelText: context.l10n.editUnitName,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => save(),
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
            icon: const Icon(Icons.merge_outlined),
            onPressed: (isSaving || isMerging) ? null : merge,
            spinnerSize: 16,
            child: Text(context.l10n.editUnitMerge),
          ),
        ],
      ),
    );
  }
}
