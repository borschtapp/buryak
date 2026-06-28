import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/food.dart';
import '../../repositories/food_repository.dart';
import '../../util/extensions.dart';
import '../searchable_list_sheet.dart';

/// Reusable bottom sheet that searches the canonical food catalog and returns
/// the picked [Food]. Used both for selecting an ingredient's food and for
/// choosing a merge target, from any feature.
class FoodPicker extends HookConsumerWidget {
  const FoodPicker({super.key, this.excludeId});

  /// Food id to hide from results (e.g. the merge source itself).
  final String? excludeId;

  /// Opens the picker and resolves with the chosen food, or `null` if dismissed.
  static Future<Food?> pick(BuildContext context, {String? excludeId}) {
    return showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FoodPicker(excludeId: excludeId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchableListSheet<Food>(
      hintText: context.l10n.editIngredientFoodSearch,
      emptySearchText: context.l10n.editIngredientFoodSearchHint,
      emptyResultsText: context.l10n.feedFilterEmptyTitle,
      minQueryLength: 2,
      search: (query) async {
        final page = await ref.read(foodRepositoryProvider).findAll(q: query, limit: 20);
        return page.data.where((f) => f.id != excludeId).toList();
      },
      itemBuilder: (context, food) => ListTile(
        title: Text(food.name),
        subtitle: food.defaultUnit != null ? Text(food.defaultUnit!.name) : null,
        onTap: () => context.pop(food),
      ),
    );
  }
}
