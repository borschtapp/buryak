import 'dart:async';

import 'package:buryak/shared/models/paginated_list.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/providers/saved.dart';
import 'package:buryak/shared/providers/user.dart';
import 'package:buryak/shared/repositories/recipe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockRecipeRepository();
    container = ProviderContainer(
      overrides: [
        recipeRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWithValue((userId: 'user-1', householdId: 'household-1')),
      ],
    );
    addTearDown(container.dispose);
  });

  /// A `findAll` call matching any arguments, capturing `scope` when [captureScope].
  Future<PaginatedList<Recipe>> findAll({bool captureScope = false}) => repo.findAll(
    preload: any(named: 'preload'),
    filter: any(named: 'filter'),
    scope: captureScope ? captureAny(named: 'scope') : any(named: 'scope'),
    limit: any(named: 'limit'),
    offset: any(named: 'offset'),
  );

  void stubFindAll(List<Recipe> recipes, {required int total}) {
    when(findAll).thenAnswer(
      (_) async => PaginatedList(
        data: recipes,
        meta: Meta(total: total, limit: 20, offset: 0),
      ),
    );
  }

  test('savedRecipes only asks for the household\'s saved recipes', () async {
    stubFindAll([Recipe.fromJson(fakeRecipeJson())], total: 2);

    container.listen(savedRecipesProvider, (_, _) {});
    await container.read(savedRecipesProvider.future);
    await container.read(savedRecipesProvider.notifier).loadMore();

    // Without a scope the server returns every visible recipe, feed recipes included,
    // which then all show as liked.
    final scopes = verify(() => findAll(captureScope: true)).captured;
    expect(scopes, ['saved', 'saved']);
  });

  test('recipeSaveToggles shows a like at once and reverts it when the request fails', () async {
    final request = Completer<void>();
    when(() => repo.save('r1')).thenAnswer((_) => request.future);

    final pending = container.read(recipeSaveTogglesProvider.notifier).toggle('r1', isSaved: false);
    expect(container.read(recipeSaveTogglesProvider), {'r1': true});

    request.completeError(Exception('offline'));
    await expectLater(pending, throwsException);
    expect(container.read(recipeSaveTogglesProvider), {'r1': false});
  });

  test('unliking keeps a recipe in Saved while another household member still likes it', () async {
    Recipe likedBy(String id, List<String> userIds) => Recipe.fromJson({
      ...fakeRecipeJson(id: id),
      'saved_by': [
        for (final userId in userIds) {'id': userId},
      ],
    });
    stubFindAll([
      likedBy('shared', ['user-1', 'user-2']),
      likedBy('mine', ['user-1']),
    ], total: 2);
    when(() => repo.unsave(any())).thenAnswer((_) async {});

    container.listen(savedRecipesProvider, (_, _) {});
    await container.read(savedRecipesProvider.future);
    final toggles = container.read(recipeSaveTogglesProvider.notifier);
    await toggles.toggle('shared', isSaved: true);
    await toggles.toggle('mine', isSaved: true);

    final saved = container.read(savedRecipesProvider).value!;
    expect(saved.map((recipe) => recipe.id), ['shared']);
    expect(saved.single.savedBy!.map((user) => user.id), ['user-2'], reason: 'only the partner still likes it');
  });
}
