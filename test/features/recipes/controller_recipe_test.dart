import 'dart:async';

import 'package:buryak/features/recipes/controller_recipe.dart';
import 'package:buryak/shared/models/recipe.dart';
import 'package:buryak/shared/models/recipe_ingredient.dart';
import 'package:buryak/shared/repositories/recipe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_recipe.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  const ingredient = RecipeIngredient(id: 'i1', name: 'flour');
  late MockRecipeRepository repo;
  late ProviderContainer container;
  late int fetches;

  setUpAll(() => registerFallbackValue(ingredient));

  setUp(() async {
    repo = MockRecipeRepository();
    container = ProviderContainer(overrides: [recipeRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    fetches = 0;
    when(() => repo.findOne('1')).thenAnswer((_) async {
      fetches++;
      return Recipe.fromJson(fakeRecipeJson());
    });
    container.listen(recipeControllerProvider('1'), (_, _) {});
    await container.read(recipeControllerProvider('1').future);
  });

  test('updateIngredient succeeds when the recipe is refreshed while the write is in flight', () async {
    final response = Completer<RecipeIngredient>();
    when(() => repo.updateIngredient('1', 'i1', any())).thenAnswer((_) => response.future);

    final pending = updateIngredientMutation.run(
      container,
      (tsx) => tsx.get(recipeControllerProvider('1').notifier).updateIngredient('i1', ingredient),
    );
    await Future<void>.delayed(Duration.zero);
    container.invalidate(recipeControllerProvider('1')); // e.g. a food edit elsewhere
    await container.read(recipeControllerProvider('1').future);
    response.complete(ingredient);

    await pending;
    await container.read(recipeControllerProvider('1').future);
    expect(fetches, 3, reason: 'initial load, the refresh, and the reload after the write');
  });

  test('refreshFromSource shows the refreshed recipe without fetching it again', () async {
    when(() => repo.refresh('1')).thenAnswer((_) async => Recipe.fromJson(fakeRecipeJson(name: 'Refreshed')));

    await refreshRecipeMutation('1').run(
      container,
      (tsx) => tsx.get(recipeControllerProvider('1').notifier).refreshFromSource(),
    );

    expect(container.read(recipeControllerProvider('1')).value?.name, 'Refreshed');
    expect(fetches, 1, reason: 'the refresh response replaces the recipe');
  });
}
