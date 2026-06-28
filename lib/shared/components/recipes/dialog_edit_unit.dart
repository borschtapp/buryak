import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/unit.dart';
import '../../providers/recipe_price.dart';
import '../../repositories/unit_repository.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import '../loading_button.dart';
import '../standard_bottom_sheet.dart';
import 'unit_merge.dart';

/// Contextual unit curation: rename a unit, or merge it into another.
///
/// Both actions are household-global, so on success the shared [allUnitsProvider]
/// is invalidated to refresh every open unit picker.
class EditUnitBottomSheet extends HookConsumerWidget {
  const EditUnitBottomSheet({super.key, required this.unit});

  final Unit unit;

  static void show(BuildContext context, {required Unit unit}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditUnitBottomSheet(unit: unit),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: unit.name);
    final isSaving = useState(false);
    final isMerging = useState(false);

    Future<void> save() async {
      final newName = nameController.text.trim();
      if (newName.isEmpty || newName == unit.name) {
        context.pop();
        return;
      }
      isSaving.value = true;
      try {
        await ref.read(unitRepositoryProvider).update(unit.id, name: newName);
        ref.invalidate(allUnitsProvider);
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
        final merged = await runUnitMergeFlow(context, ref, source: unit);
        if (merged) {
          ref.invalidate(allUnitsProvider);
          if (context.mounted) context.pop();
        }
      } finally {
        if (context.mounted) isMerging.value = false;
      }
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
            isLoading: isSaving.value,
            onPressed: save,
            child: Text(context.l10n.save),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          LoadingButton(
            type: LoadingButtonType.text,
            isLoading: isMerging.value,
            icon: const Icon(Icons.merge_outlined),
            onPressed: (isSaving.value || isMerging.value) ? null : merge,
            spinnerSize: 16,
            child: Text(context.l10n.editUnitMerge),
          ),
        ],
      ),
    );
  }
}
