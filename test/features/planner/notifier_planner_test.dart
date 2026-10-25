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
      (tsx) => tsx.get(mealPlanWriterProvider).createPlan(today, MealType.dinner, recipeId: 'r1', servings: 4),
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
      (tsx) => tsx.get(mealPlanWriterProvider).editPlan('p1', date: today, mealType: MealType.lunch, servings: 3),
    );

    expect(container.read(mealPlanWeekProvider).value, [updated]);
  });

  test('createPlan succeeds when the week is refreshed while the write is in flight', () async {
    final created = MealPlan(id: 'p2', date: today, mealType: MealType.dinner, recipeId: 'r1', servings: 4);
    final response = Completer<MealPlan>();
    when(() => repo.create(today, MealType.dinner, recipeId: 'r1', servings: 4)).thenAnswer((_) => response.future);

    final pending = saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWriterProvider).createPlan(today, MealType.dinner, recipeId: 'r1', servings: 4),
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
    final nextWeek = DateTime(today.year, today.month, today.day + 7);
    final created = MealPlan(id: 'p2', date: nextWeek, mealType: MealType.dinner, recipeId: 'r1', servings: 4);
    when(() => repo.create(nextWeek, MealType.dinner, recipeId: 'r1', servings: 4)).thenAnswer((_) async => created);

    await saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWriterProvider).createPlan(nextWeek, MealType.dinner, recipeId: 'r1', servings: 4),
    );

    expect(container.read(mealPlanWeekProvider).value, [existing]);
  });

  // The server sends plan dates as UTC midnight. Only a negative UTC offset
  // shows the difference, so also run this file with `TZ=America/New_York`.
  test('saved plans are placed in the week by calendar date, in any time zone', () async {
    final todayUtc = DateTime.utc(today.year, today.month, today.day);
    final saved = {
      today: MealPlan(id: 'p2', date: todayUtc, mealType: MealType.dinner, servings: 1),
      DateTime(today.year, today.month, today.day + 6): MealPlan(
        id: 'p3',
        date: todayUtc.add(const Duration(days: 6)),
        mealType: MealType.dinner,
        servings: 1,
      ),
      DateTime(today.year, today.month, today.day + 7): MealPlan(
        id: 'p4',
        date: todayUtc.add(const Duration(days: 7)),
        mealType: MealType.dinner,
        servings: 1,
      ),
    };
    for (final MapEntry(key: date, value: plan) in saved.entries) {
      when(() => repo.create(date, MealType.dinner, recipeId: 'r1', servings: 1)).thenAnswer((_) async => plan);
      await saveMealPlanMutation.run(
        container,
        (tsx) => tsx.get(mealPlanWriterProvider).createPlan(date, MealType.dinner, recipeId: 'r1', servings: 1),
      );
    }

    expect(container.read(mealPlanWeekProvider).value?.map((p) => p.id), ['p1', 'p2', 'p3']);
  });

  // Clocks go back in Europe on 2026-10-25 and in the US on 2026-11-01, so
  // run this with `TZ=Europe/Berlin` or `TZ=America/New_York` to see it fail.
  test('the week is requested up to its seventh calendar day across a DST change', () async {
    for (final start in [DateTime(2026, 10, 25), DateTime(2026, 11, 1)]) {
      final week = ProviderContainer(
        overrides: [
          mealPlanRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
          currentDateProvider.overrideWithValue(AsyncData(start)),
        ],
      );
      addTearDown(week.dispose);
      clearInteractions(repo);

      await week.read(mealPlanWeekProvider.future);

      final to = verify(() => repo.findAll(from: start, to: captureAny(named: 'to'))).captured.single;
      expect(to, DateTime(start.year, start.month, start.day + 6), reason: 'week starting $start');
    }
  });

  test('editPlan moving a plan out of this week removes it', () async {
    final moved = existing.copyWith(date: DateTime(today.year, today.month, today.day + 10));
    when(
      () => repo.update('p1', date: moved.date, mealType: MealType.lunch, servings: 2),
    ).thenAnswer((_) async => moved);

    await saveMealPlanMutation.run(
      container,
      (tsx) => tsx.get(mealPlanWriterProvider).editPlan('p1', date: moved.date, mealType: MealType.lunch, servings: 2),
    );

    expect(container.read(mealPlanWeekProvider).value, isEmpty);
  });

  test('createPlan before the week was ever shown loads nothing, and the week later includes the plan', () async {
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

    clearInteractions(repo); // setUp loaded the week of the other container
    await saveMealPlanMutation.run(
      cold,
      (tsx) => tsx.get(mealPlanWriterProvider).createPlan(today, MealType.dinner, recipeId: 'r1', servings: 4),
    );
    verifyNever(
      () => repo.findAll(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    );
    week.complete();

    expect(await cold.read(mealPlanWeekProvider.future), [existing, created]);
  });
}
