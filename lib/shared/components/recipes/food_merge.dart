import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/shopping/notifier_shopping.dart';
import '../../models/food.dart';
import '../../providers/recipe_price.dart';
import '../../repositories/food_repository.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../dialog_confirm.dart';
import 'food_picker_sheet.dart';

/// Runs the full contextual food-merge flow: pick a target food, confirm the
/// (global, irreversible) survivorship, then call the merge API.
///
/// Returns `true` only when the merge succeeded, so the caller can invalidate
/// its own caches (recipe, shopping list, …) and close its sheet. Cancellation
/// at any step returns `false`. Errors are surfaced via [ref.handleException]
/// and also return `false`.
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

  try {
    await ref.read(foodRepositoryProvider).merge(source.id, target.id);
    ref.invalidate(shoppingItemsProvider);
    ref.invalidate(foodPricesProvider(source.id));
    ref.invalidate(foodPricesProvider(target.id));
    return true;
  } catch (e) {
    ref.handleException(e);
    return false;
  }
}
