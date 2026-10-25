import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/meal_plan.dart';
import '../../shared/providers/date.dart';
import '../../shared/providers/user.dart';
import '../../shared/repositories/meal_plan_repository.dart';

part 'notifier_planner.g.dart';

// Run with `tsx.get(mealPlanWriterProvider)`.
final saveMealPlanMutation = Mutation<void>(label: 'saveMealPlan');

@Riverpod(keepAlive: true)
MealPlanWriter mealPlanWriter(Ref ref) => MealPlanWriter(ref);

/// Creates and edits meal plans. Kept off [MealPlanWeek] so adding a recipe to
/// the plan from the recipe screen doesn't load a week nobody is showing.
class MealPlanWriter {
  MealPlanWriter(this._ref);

  final Ref _ref;

  Future<void> createPlan(DateTime date, MealType mealType, {required String recipeId, required int servings}) async {
    final created = await _ref.read(mealPlanRepositoryProvider).create(date, mealType, recipeId: recipeId, servings: servings);
    _applySaved(created);
  }

  Future<void> editPlan(String id, {required DateTime date, required MealType mealType, required int servings}) async {
    final updated = await _ref.read(mealPlanRepositoryProvider).update(id, date: date, mealType: mealType, servings: servings);
    _applySaved(updated);
  }

  // A week that was never loaded will fetch the plan along with the rest.
  void _applySaved(MealPlan plan) {
    if (_ref.exists(mealPlanWeekProvider)) _ref.read(mealPlanWeekProvider.notifier).applySaved(plan);
  }
}

@Riverpod(keepAlive: true)
class MealPlanWeek extends _$MealPlanWeek {
  @override
  FutureOr<List<MealPlan>> build() async {
    ref.watchSession();
    final from = _weekStart(ref.watch(currentDateProvider).value);
    // Calendar days, not 6 × 24 h, which ends a day early when clocks go back.
    final to = DateTime(from.year, from.month, from.day + 6);
    final result = await ref.read(mealPlanRepositoryProvider).findAll(from: from, to: to);
    return result.data;
  }

  static DateTime _weekStart(DateTime? now) {
    now ??= DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Puts the server's copy of [plan] into the week instead of re-fetching it:
  /// replaced in place, added, or dropped when its date is outside the week.
  /// Called by [MealPlanWriter].
  void applySaved(MealPlan plan) {
    final plans = state.value;
    // A load still in flight may have been sent before this write, so its result
    // can't be patched reliably: fetch the week again instead.
    if (plans == null || state.isLoading) {
      ref.invalidateSelf();
      return;
    }

    final from = _weekStart(ref.read(currentDateProvider).value);
    // Plan dates are UTC midnight and `from` is local midnight: compare calendar days.
    final day = DateTime(plan.date.year, plan.date.month, plan.date.day);
    final inWeek = !day.isBefore(from) && day.isBefore(DateTime(from.year, from.month, from.day + 7));
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
