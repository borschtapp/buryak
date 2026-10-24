import 'dart:async';

import 'package:buryak/shared/models/collection.dart';
import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/providers/saved.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/collection_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements CollectionRepository {}

void main() {
  late MockCollectionRepository repo;
  late ProviderContainer container;
  late int fetches;

  setUp(() async {
    repo = MockCollectionRepository();
    container = ProviderContainer(
      overrides: [
        collectionRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
      ],
    );
    addTearDown(container.dispose);
    fetches = 0;
    when(
      () => repo.findAll(
        preload: any(named: 'preload'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async {
      fetches++;
      return PaginatedList(
        data: const [Collection(id: 'c1', userId: 'user-1', name: 'Soups')],
        meta: const Meta(total: 1, limit: 20, offset: 0),
      );
    });
    container.listen(savedCollectionsProvider, (_, _) {});
    await container.read(savedCollectionsProvider.future);
  });

  test('updateRecipeCollections succeeds when collections are refreshed while the write is in flight', () async {
    final added = Completer<void>();
    when(() => repo.addRecipe('c1', 'r1')).thenAnswer((_) => added.future);

    final pending = updateRecipeCollectionsMutation.run(
      container,
      (tsx) => tsx.get(savedCollectionsProvider.notifier).updateRecipeCollections('r1', add: {'c1'}, remove: {}),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(savedCollectionsProvider);
    await container.read(savedCollectionsProvider.future);
    added.complete();

    await pending;
    await container.read(savedCollectionsProvider.future);
    expect(fetches, 3, reason: 'initial load, the refresh, and the reload after the write');
  });
}
