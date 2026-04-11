import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/providers/saved.dart';
import '../../shared/repositories/recipe_repository.dart';

part 'controller_recipe.g.dart';

@riverpod
class RecipeController extends _$RecipeController {
  @override
  Future<Recipe> build(String recipeId) {
    return ref.watch(recipeRepositoryProvider).findOne(recipeId);
  }

  void updateCollections(List<Collection> collections) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(collections: collections));
    }
  }

  Future<void> toggleSaved() async {
    final isSaved = ref.read(recipeIsSavedProvider(recipeId));

    if (!isSaved) {
      await ref.read(recipeRepositoryProvider).save(recipeId);
      ref.invalidate(savedRecipesProvider);
    } else {
      // Optimistic in-place removal
      ref.read(savedRecipesProvider.notifier).remove(recipeId);
      try {
        await ref.read(recipeRepositoryProvider).unsave(recipeId);
      } catch (e) {
        // Revert on error by forcing a fresh fetch
        ref.invalidate(savedRecipesProvider);
        rethrow;
      }
    }
  }
}

/// Returns the current saved state of a recipe and a toggle callback.
/// Lightweight helper for recipe tiles that already have the recipe object.
({bool isSaved, Future<void> Function() toggle}) savedRecipeState(WidgetRef ref, String recipeId) {
  final isSaved = ref.watch(recipeIsSavedProvider(recipeId));
  return (
    isSaved: isSaved,
    toggle: () => ref.read(recipeControllerProvider(recipeId).notifier).toggleSaved(),
  );
}
