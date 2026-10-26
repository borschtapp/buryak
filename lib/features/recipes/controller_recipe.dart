import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/providers/food_catalog.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/repositories/recipe_repository.dart';

part 'controller_recipe.g.dart';

// Run with `tsx.get(recipeControllerProvider(id).notifier)`: the transaction
// keeps this auto-disposed controller alive until the write has finished.
final updateIngredientMutation = Mutation<void>(label: 'updateIngredient');
final deleteIngredientMutation = Mutation<void>(label: 'deleteIngredient');

@riverpod
class RecipeController extends _$RecipeController {
  @override
  Future<Recipe> build(String recipeId) {
    ref.watch(foodCatalogChangedProvider(.recipes));
    return ref.watch(recipeRepositoryProvider).findOne(recipeId);
  }

  void updateCollections(List<Collection> collections) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(collections: collections));
    }
  }

  Future<void> updateIngredient(String ingredientId, RecipeIngredient updated) async {
    await ref.read(recipeRepositoryProvider).updateIngredient(recipeId, ingredientId, updated);
    _ingredientsChanged();
  }

  Future<void> deleteIngredient(String ingredientId) async {
    await ref.read(recipeRepositoryProvider).deleteIngredient(recipeId, ingredientId);
    _ingredientsChanged();
  }

  /// Last step of each write: rebuilding replaces this notifier, so nothing after it may use ref or state.
  void _ingredientsChanged() {
    ref.invalidate(recipeCostEstimateProvider(recipeId));
    ref.invalidateSelf();
  }
}
