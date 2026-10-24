import 'dart:async';

import 'package:buryak/shared/models/food.dart';
import 'package:buryak/shared/models/food_price.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/unit.dart';
import 'package:buryak/shared/providers/error_handler.dart';
import 'package:buryak/shared/providers/food_catalog.dart';
import 'package:buryak/shared/providers/recipe_price.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/food_repository.dart';
import 'package:buryak/shared/repositories/repository.dart';
import 'package:buryak/shared/repositories/unit_repository.dart';
import 'package:buryak/shared/util/error_extensions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodRepository extends Mock implements FoodRepository {}

class MockUnitRepository extends Mock implements UnitRepository {}

PaginatedList<T> _page<T>(List<T> data) => PaginatedList(
  data: data,
  meta: Meta(total: data.length, limit: 20, offset: 0),
);

void main() {
  late MockFoodRepository foods;
  late MockUnitRepository units;
  late ProviderContainer container;

  setUp(() {
    foods = MockFoodRepository();
    units = MockUnitRepository();
    container = ProviderContainer(
      observers: [MutationErrorReporter()],
      overrides: [
        foodRepositoryProvider.overrideWithValue(foods),
        unitRepositoryProvider.overrideWithValue(units),
        sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
      ],
    );
    when(() => foods.findPrices('f1', limit: 20)).thenAnswer((_) async => _page(<FoodPrice>[]));
  });

  tearDown(() => container.dispose());

  /// Keeps the food's price list mounted (as an open sheet would) and loads it once.
  Future<void> watchPrices() async {
    container.listen(foodPricesProvider('f1'), (_, _) {});
    await container.read(foodPricesProvider('f1').future);
  }

  test('recordPrice refreshes that food\'s prices and remembers the unit', () async {
    when(() => foods.recordPrice('f1', 2.5, 1, 'u1')).thenAnswer(
      (_) async => FoodPrice(
        id: 'p1',
        foodId: 'f1',
        unitId: 'u1',
        householdId: 'h1',
        price: 2.5,
        amount: 1,
        created: DateTime(2026),
      ),
    );
    await watchPrices();

    await recordPriceMutation.run(container, (tsx) => tsx.get(foodCatalogProvider).recordPrice('f1', 2.5, 1, 'u1'));
    await container.read(foodPricesProvider('f1').future);

    verify(() => foods.findPrices('f1', limit: 20)).called(2);
    expect(container.read(foodUnitPreferencesProvider)['f1'], 'u1');
  });

  test('a failed write is reported once, refreshes nothing, and tryRun resolves to false', () async {
    when(() => foods.deletePrice('f1', 'p1')).thenThrow(GeneralApiException(message: '', statusCode: 500));
    final errors = <ErrorMessage?>[];
    container.listen(errorHandlerProvider, (_, next) => errors.add(next));
    container.listen(deletePriceMutation, (_, _) {});
    await watchPrices();

    final ok = await deletePriceMutation.tryRun(container, (tsx) => tsx.get(foodCatalogProvider).deletePrice('f1', 'p1'));

    expect(ok, isFalse);
    expect(errors.single?.messageKey, ErrorMessageKey.serverError);
    expect(container.read(deletePriceMutation), isA<MutationError<void>>());
    verify(() => foods.findPrices('f1', limit: 20)).called(1);
  });

  test('overlapping deletes of different prices each report their own failure', () async {
    final first = Completer<void>();
    final second = Completer<void>();
    when(() => foods.deletePrice('f1', 'p1')).thenAnswer((_) => first.future);
    when(() => foods.deletePrice('f1', 'p2')).thenAnswer((_) => second.future);
    final errors = <ErrorMessage?>[];
    container.listen(errorHandlerProvider, (_, next) => errors.add(next));

    // As the price sheet runs them: one mutation per swiped price.
    final a = deletePriceMutation('p1').tryRun(container, (tsx) => tsx.get(foodCatalogProvider).deletePrice('f1', 'p1'));
    final b = deletePriceMutation('p2').tryRun(container, (tsx) => tsx.get(foodCatalogProvider).deletePrice('f1', 'p2'));
    first.completeError(GeneralApiException(message: '', statusCode: 500));
    second.completeError(GeneralApiException(message: '', statusCode: 500));

    expect(await a, isFalse);
    expect(await b, isFalse);
    expect(errors, hasLength(2));
  });

  test('updateFood with no changed fields sends nothing', () async {
    await updateFoodMutation.run(container, (tsx) => tsx.get(foodCatalogProvider).updateFood('f1'));

    verifyZeroInteractions(foods);
  });

  test('updateFood counts clearing the default unit as a change', () async {
    when(() => foods.update('f1', clearDefaultUnit: true)).thenAnswer((_) async => const Food(id: 'f1', slug: 'f', name: 'f'));

    await updateFoodMutation.run(
      container,
      (tsx) => tsx.get(foodCatalogProvider).updateFood('f1', clearDefaultUnit: true),
    );

    verify(() => foods.update('f1', clearDefaultUnit: true)).called(1);
  });

  test('renameUnit refreshes the unit catalog', () async {
    when(() => units.findAll(limit: 200)).thenAnswer((_) async => _page(const [Unit(id: 'u1', slug: 'g', name: 'g')]));
    when(() => units.update('u1', name: 'gram')).thenAnswer((_) async => const Unit(id: 'u1', slug: 'g', name: 'gram'));
    container.listen(allUnitsProvider, (_, _) {});
    await container.read(allUnitsProvider.future);

    await renameUnitMutation.run(container, (tsx) => tsx.get(foodCatalogProvider).renameUnit('u1', 'gram'));
    await container.read(allUnitsProvider.future);

    verify(() => units.findAll(limit: 200)).called(2);
  });

  testWidgets('a write started from a widget still finishes and refreshes after the widget is gone', (tester) async {
    final request = Completer<void>();
    when(() => foods.deletePrice('f1', 'p1')).thenAnswer((_) => request.future);
    await watchPrices();

    late WidgetRef widgetRef;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            widgetRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );

    final result = deletePriceMutation.tryRun(widgetRef, (tsx) => tsx.get(foodCatalogProvider).deletePrice('f1', 'p1'));
    // The sheet is dismissed while the request is in flight.
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const SizedBox()));
    request.complete();

    expect(await result, isTrue);
    await container.read(foodPricesProvider('f1').future);
    verify(() => foods.findPrices('f1', limit: 20)).called(2);
    expect(tester.takeException(), isNull);
  });
}
