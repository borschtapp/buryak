import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/unit.dart';
import '../../providers/recipe_price.dart';
import '../../util/extensions.dart';
import '../searchable_list_sheet.dart';
import 'dialog_edit_unit.dart';

/// Reusable bottom sheet that lists the unit catalog (from [allUnitsProvider])
/// with client-side search and returns the picked [Unit].
///
/// When [allowEdit] is true each row exposes an edit affordance that opens
/// [EditUnitBottomSheet] for inline rename / merge — this is the contextual
/// surface where duplicate units ("g" vs "gram") are actually noticed. The
/// affordance is disabled when the picker is itself used to choose a merge
/// target, to avoid recursive editing.
class UnitPicker extends HookConsumerWidget {
  const UnitPicker({super.key, this.allowEdit = true, this.excludeId});

  final bool allowEdit;

  /// Unit id to hide from results (e.g. the merge source itself).
  final String? excludeId;

  static Future<Unit?> pick(
    BuildContext context, {
    bool allowEdit = true,
    String? excludeId,
  }) {
    return showModalBottomSheet<Unit>(
      context: context,
      isScrollControlled: true,
      builder: (_) => UnitPicker(allowEdit: allowEdit, excludeId: excludeId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(allUnitsProvider);
    final units = unitsAsync.value ?? const <Unit>[];

    return SearchableListSheet<Unit>(
      initialLoading: unitsAsync.isLoading,
      hintText: context.l10n.foodPriceUnitSearch,
      emptyResultsText: context.l10n.feedFilterEmptyTitle,
      debounceDuration: Duration.zero,
      search: (query) {
        final available = units.where((u) => u.id != excludeId);
        if (query.isEmpty) return available.toList();
        return available.where((u) => u.name.toLowerCase().contains(query.toLowerCase())).toList();
      },
      itemBuilder: (context, unit) => ListTile(
        title: Text(unit.name),
        trailing: allowEdit
            ? IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: context.l10n.editUnitTitle,
                onPressed: () => EditUnitBottomSheet.show(context, unit: unit),
              )
            : null,
        onTap: () => context.pop(unit),
      ),
    );
  }
}
