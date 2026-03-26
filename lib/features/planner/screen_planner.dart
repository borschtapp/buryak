import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/components/error_state.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/providers/date.dart';
import '../../shared/repositories/meal_plan_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import 'dialog_edit_plan.dart';

part 'screen_planner.g.dart';

@Riverpod(keepAlive: true)
class MealPlanWeek extends _$MealPlanWeek {
  @override
  FutureOr<List<MealPlan>> build() async {
    final now = ref.watch(currentDateProvider).value ?? DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(const Duration(days: 6));
    final result = await ref.read(mealPlanRepositoryProvider).findAll(from: from, to: to);
    return result.data;
  }

  void updatePlan(MealPlan updated) {
    state = state.whenData((plans) => plans.map((p) => p.id == updated.id ? updated : p).toList());
  }

  void addPlan(MealPlan plan) {
    state = state.whenData((plans) => [...plans, plan]);
  }

  Future<void> deletePlan(String id) async {
    final previousState = state;

    state = state.whenData((plans) => plans.where((p) => p.id != id).toList());

    try {
      await ref.read(mealPlanRepositoryProvider).delete(id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanAsync = ref.watch(mealPlanWeekProvider);

    return mealPlanAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return EmptyState(
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
              return Dismissible(
                key: ValueKey(entry.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  final itemName = entry.recipe?.name ?? entry.description ?? 'Meal plan';
                  try {
                    await ref.read(mealPlanWeekProvider.notifier).deletePlan(entry.id);
                    if (context.mounted) {
                      SemanticsService.sendAnnouncement(View.of(context), '$itemName removed', TextDirection.ltr);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to remove meal plan.')),
                      );
                    }
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
                  onTap: entry.recipeId != null ? () => context.goNamed(RouteNames.recipe, pathParameters: {'rid': entry.recipeId!}) : null,
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(mealPlanWeekProvider),
      ),
    );
  }
}
