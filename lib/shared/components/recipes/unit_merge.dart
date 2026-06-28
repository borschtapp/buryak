import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/shopping/notifier_shopping.dart';
import '../../models/unit.dart';
import '../../providers/recipe_price.dart';
import '../../repositories/unit_repository.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../dialog_confirm.dart';
import 'unit_picker_sheet.dart';

/// Runs the contextual unit-merge flow: pick a target unit, confirm the
/// (global, irreversible) survivorship, then call the merge API.
///
/// Returns `true` only when the merge succeeded, so the caller can invalidate
/// its own caches (`allUnitsProvider`, recipe estimates, …) and close its sheet.
/// Cancellation returns `false`; errors are surfaced via [ref.handleException]
/// and also return `false`.
///
/// The merge-target picker disables its own edit affordance to avoid opening an
/// edit sheet recursively from within the merge flow.
Future<bool> runUnitMergeFlow(
  BuildContext context,
  WidgetRef ref, {
  required Unit source,
}) async {
  final target = await UnitPicker.pick(context, allowEdit: false, excludeId: source.id);
  if (target == null || !context.mounted) return false;

  final confirmed = await showConfirmDialog(
    context,
    title: context.l10n.editUnitMergeTitle,
    content: context.l10n.editUnitMergeMessage(source.name, target.name),
    confirmLabel: context.l10n.editUnitMergeConfirm,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return false;

  try {
    await ref.read(unitRepositoryProvider).merge(source.id, target.id);
    ref.invalidate(shoppingItemsProvider);
    ref.invalidate(foodPricesProvider);
    return true;
  } catch (e) {
    ref.handleException(e);
    return false;
  }
}
