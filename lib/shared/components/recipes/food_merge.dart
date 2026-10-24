import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/food.dart';
import '../../providers/food_catalog.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../dialog_confirm.dart';
import 'food_picker_sheet.dart';

/// Runs the full contextual food-merge flow: pick a target food, confirm the
/// (global, irreversible) survivorship, then call the merge API.
///
/// Returns `true` only when the merge succeeded, so the caller can close its
/// sheet; [FoodCatalog] refreshes the affected caches. Cancellation at any step
/// returns `false`, as does a failed merge, which [MutationErrorReporter] reports.
///
/// Merging is global across the household — every recipe, shopping item, and
/// saved price referencing [source] is reassigned to the chosen target — so the
/// confirmation spells out the before → after explicitly.
Future<bool> runFoodMergeFlow(
  BuildContext context,
  WidgetRef ref, {
  required Food source,
}) async {
  final target = await FoodPicker.pick(context, excludeId: source.id);
  if (target == null || !context.mounted) return false;

  final confirmed = await showConfirmDialog(
    context,
    title: context.l10n.editFoodMergeTitle,
    content: context.l10n.editFoodMergeMessage(source.name, target.name),
    confirmLabel: context.l10n.editFoodMergeConfirm,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return false;

  return mergeFoodsMutation.tryRun(ref, (tsx) => tsx.get(foodCatalogProvider).mergeFoods(source.id, target.id));
}
