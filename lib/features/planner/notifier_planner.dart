import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/meal_plan.dart';
import '../../shared/providers/date.dart';
import '../../shared/providers/user.dart';
import '../../shared/repositories/meal_plan_repository.dart';

part 'notifier_planner.g.dart';

// Run with `tsx.get(mealPlanWeekProvider.notifier)`.
final saveMealPlanMutation = Mutation<void>(label: 'saveMealPlan');

@Riverpod(keepAlive: true)
class MealPlanWeek extends _$MealPlanWeek {
  @override
  FutureOr<List<MealPlan>> build() async {
    ref.watchSession();
    final from = _weekStart(ref.watch(currentDateProvider).value);
    final to = from.add(const Duration(days: 6));
    final result = await ref.read(mealPlanRepositoryProvider).findAll(from: from, to: to);
    return result.data;
  }

  static DateTime _weekStart(DateTime? now) {
    now ??= DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> createPlan(DateTime date, MealType mealType, {required String recipeId, required int servings}) async {
    final created = await ref.read(mealPlanRepositoryProvider).create(date, mealType, recipeId: recipeId, servings: servings);
    _applySaved(created);
  }

  Future<void> editPlan(String id, {required DateTime date, required MealType mealType, required int servings}) async {
    final updated = await ref.read(mealPlanRepositoryProvider).update(id, date: date, mealType: mealType, servings: servings);
    _applySaved(updated);
  }

  /// Puts the server's copy of [plan] into the week instead of re-fetching it:
  /// replaced in place, added, or dropped when its date is outside the week.
  void _applySaved(MealPlan plan) {
    final plans = state.value;
    // A load still in flight may have been sent before this write, so its result
    // can't be patched reliably: fetch the week again instead.
    if (plans == null || state.isLoading) {
      ref.invalidateSelf();
      return;
    }

    final from = _weekStart(ref.read(currentDateProvider).value);
    final inWeek = !plan.date.isBefore(from) && plan.date.isBefore(from.add(const Duration(days: 7)));
    final exists = plans.any((p) => p.id == plan.id);
    state = AsyncData([
      for (final p in plans)
        if (p.id != plan.id) p else if (inWeek) plan,
      if (inWeek && !exists) plan,
    ]);
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
