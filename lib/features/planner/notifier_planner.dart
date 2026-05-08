import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/meal_plan.dart';
import '../../shared/providers/date.dart';
import '../../shared/repositories/meal_plan_repository.dart';

part 'notifier_planner.g.dart';

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
