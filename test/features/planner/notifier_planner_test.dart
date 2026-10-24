import 'dart:async';

import 'package:buryak/features/planner/notifier_planner.dart';
import 'package:buryak/shared/models/meal_plan.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/providers/date.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/meal_plan_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockMealPlanRepository extends Mock implements MealPlanRepository {}

void main() {
  final today = DateTime(2026, 10, 24);
  final existing = MealPlan(id: 'p1', date: today, mealType: MealType.lunch, servings: 2);
  late MockMealPlanRepository repo;
  late ProviderContainer container;

  setUp(() async {
    repo = MockMealPlanRepository();
    container = ProviderContainer(
      overrides: [
        mealPlanRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
        currentDateProvider.overrideWithValue(AsyncData(today)),
      ],
    );
    addTearDown(container.dispose);
    when(
      () => repo.findAll(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => PaginatedList(data: [existing], meta: const Meta(total: 1, limit: 20, offset: 0)));
    container.listen(mealPlanWeekProvider, (_, _) {});
    await container.read(mealPlanWeekProvider.future);
  });

  test('createPlan appends the created plan without re-fetching the week', () async {
    final created = MealPlan(id: 'p2', date: today, mealType: MealType.dinner, recipeId: 'r1', servings: 4);
    when(() => repo.create(today, MealType.dinner, recipeId: 'r1', servings: 4)).thenAnswer((_) async => created);

    await saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWeekProvider.notifier).createPlan(today, MealType.dinner, recipeId: 'r1', servings: 4),
    );

    expect(container.read(mealPlanWeekProvider).value, [existing, created]);
    verify(
      () => repo.findAll(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).called(1);
  });

  test('editPlan replaces the plan with the server response', () async {
    final updated = existing.copyWith(servings: 3);
    when(
      () => repo.update('p1', date: today, mealType: MealType.lunch, servings: 3),
    ).thenAnswer((_) async => updated);

    await saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWeekProvider.notifier).editPlan('p1', date: today, mealType: MealType.lunch, servings: 3),
    );

    expect(container.read(mealPlanWeekProvider).value, [updated]);
  });

  test('createPlan succeeds when the week is refreshed while the write is in flight', () async {
    final created = MealPlan(id: 'p2', date: today, mealType: MealType.dinner, recipeId: 'r1', servings: 4);
    final response = Completer<MealPlan>();
    when(() => repo.create(today, MealType.dinner, recipeId: 'r1', servings: 4)).thenAnswer((_) => response.future);

    final pending = saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWeekProvider.notifier).createPlan(today, MealType.dinner, recipeId: 'r1', servings: 4),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(mealPlanWeekProvider);
    await container.read(mealPlanWeekProvider.future);
    // The server now has the new plan, and the week re-fetched before it existed.
    when(
      () => repo.findAll(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => PaginatedList(data: [existing, created], meta: const Meta(total: 2, limit: 20, offset: 0)));
    response.complete(created);

    await pending;
    expect(await container.read(mealPlanWeekProvider.future), [existing, created]);
  });

  test('createPlan for a later week does not land in this week', () async {
    final nextWeek = today.add(const Duration(days: 7));
    final created = MealPlan(id: 'p2', date: nextWeek, mealType: MealType.dinner, recipeId: 'r1', servings: 4);
    when(() => repo.create(nextWeek, MealType.dinner, recipeId: 'r1', servings: 4)).thenAnswer((_) async => created);

    await saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWeekProvider.notifier).createPlan(nextWeek, MealType.dinner, recipeId: 'r1', servings: 4),
    );

    expect(container.read(mealPlanWeekProvider).value, [existing]);
  });

  test('editPlan moving a plan out of this week removes it', () async {
    final moved = existing.copyWith(date: today.add(const Duration(days: 10)));
    when(
      () => repo.update('p1', date: moved.date, mealType: MealType.lunch, servings: 2),
    ).thenAnswer((_) async => moved);

    await saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWeekProvider.notifier).editPlan('p1', date: moved.date, mealType: MealType.lunch, servings: 2),
    );

    expect(container.read(mealPlanWeekProvider).value, isEmpty);
  });

  test('createPlan before the week has loaded reloads it rather than dropping the plan', () async {
    final cold = ProviderContainer(
      overrides: [
        mealPlanRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
        currentDateProvider.overrideWithValue(AsyncData(today)),
      ],
    );
    addTearDown(cold.dispose);
    final created = MealPlan(id: 'p2', date: today, mealType: MealType.dinner, recipeId: 'r1', servings: 4);
    final week = Completer<void>();
    var serverPlans = [existing];
    when(
      () => repo.findAll(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async {
      final snapshot = serverPlans; // taken when the request is sent
      await week.future;
      return PaginatedList(
        data: snapshot,
        meta: Meta(total: snapshot.length, limit: 20, offset: 0),
      );
    });
    when(() => repo.create(today, MealType.dinner, recipeId: 'r1', servings: 4)).thenAnswer((_) async {
      serverPlans = [existing, created];
      return created;
    });

    await saveMealPlanMutation.run(
      cold,
      (tsx) => tsx.get(mealPlanWeekProvider.notifier).createPlan(today, MealType.dinner, recipeId: 'r1', servings: 4),
    );
    week.complete();

    expect(await cold.read(mealPlanWeekProvider.future), [existing, created]);
  });
}
