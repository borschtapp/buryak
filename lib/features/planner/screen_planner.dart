import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';

import '../../shared/extensions.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/repositories/meal_plan_repository.dart';
import '../../shared/route_names.dart';

import '../../shared/providers/date.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';

part 'screen_planner.g.dart';

@Riverpod(keepAlive: true)
Future<List<MealPlan>> mealPlanWeek(Ref ref) async {
  final now = ref.watch(currentDateProvider).value ?? DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  final to = from.add(const Duration(days: 6));
  final result = await ref.read(mealPlanRepositoryProvider).findAll(from: from, to: to);
  return result.data;
}

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(mealPlanWeekProvider);

    return mealPlanAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return EmptyStateView(
            icon: Icons.calendar_today_outlined,
            title: 'No meals planned this week.',
            action: TextButton.icon(
              onPressed: () => ref.invalidate(mealPlanWeekProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(mealPlanWeekProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, _) => const Divider(),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: Text(entry.recipe?.name ?? entry.description ?? 'Meal'),
                subtitle: Text(
                  '${DateFormat('MMM d').format(entry.date)} · ${entry.mealType.name.capitalize()}',
                ),
                trailing: Text(
                  '${entry.servings ?? 1} serving${(entry.servings ?? 1) == 1 ? '' : 's'}',
                  style: context.textTheme.bodySmall,
                ),
                onTap: entry.recipeId != null
                    ? () => context.goNamed(RouteNames.recipe, pathParameters: {'rid': entry.recipeId!})
                    : null,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(mealPlanWeekProvider),
      ),
    );
  }
}
