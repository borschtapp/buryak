import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../shared/components/dismissible_tile.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/route_names.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'dialog_edit_plan.dart';
import 'notifier_planner.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(mealPlanWeekProvider);

    return AppListScaffold<List<MealPlan>>(
      value: mealPlanAsync,
      onRefresh: () async => ref.invalidate(mealPlanWeekProvider),
      isEmpty: (data) => data.isEmpty,
      emptyState: EmptyState(
        icon: Icons.calendar_today_outlined,
        title: context.l10n.plannerEmptyTitle,
        subtitle: context.l10n.plannerEmptySubtitle,
        action: TextButton.icon(
          onPressed: () => ref.invalidate(mealPlanWeekProvider),
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.refresh),
        ),
      ),
      data: (entries) => ListView.separated(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        itemCount: entries.length,
        separatorBuilder: (context, _) => const Divider(),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return DismissibleTile(
            key: ValueKey(entry.id),
            label: entry.recipe?.name ?? entry.description ?? context.l10n.plannerMealPlanFallback,
            onDelete: () async {
              try {
                await ref.read(mealPlanWeekProvider.notifier).deletePlan(entry.id);
              } catch (e) {
                ref.handleException(e);
              }
            },
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(entry.recipe?.name ?? entry.description ?? context.l10n.plannerMealFallback),
              subtitle: Text(
                '${DateFormat('MMM d', context.l10n.localeName).format(entry.date)} · ${entry.mealType.localized(context.l10n)}',
              ),
              trailing: Text(
                context.l10n.plannerServingsCount(entry.servings ?? 1),
                style: context.textTheme.bodySmall,
              ),
              onTap: entry.recipeId != null ? () => context.pushNamed(RouteNames.recipe, pathParameters: {'rid': entry.recipeId!}) : null,
              onLongPress: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PlanBottomSheet(plan: entry),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
