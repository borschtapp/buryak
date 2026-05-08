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
        title: 'No meals planned this week.',
        action: TextButton.icon(
          onPressed: () => ref.invalidate(mealPlanWeekProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ),
      data: (entries) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (context, _) => const Divider(),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return DismissibleTile(
            key: ValueKey(entry.id),
            label: entry.recipe?.name ?? entry.description ?? 'Meal plan',
            onDelete: () async {
              try {
                await ref.read(mealPlanWeekProvider.notifier).deletePlan(entry.id);
              } catch (e) {
                ref.handleException(e);
              }
            },
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(entry.recipe?.name ?? entry.description ?? 'Meal'),
              subtitle: Text(
                '${DateFormat('MMM d').format(entry.date)} · ${entry.mealType.name.capitalize()}',
              ),
              trailing: Text(
                (entry.servings ?? 1).pluralize('serving'),
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
