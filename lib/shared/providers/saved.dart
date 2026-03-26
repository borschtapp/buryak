import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/collection.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../paged_notifier_mixin.dart';
import '../repositories/collection_repository.dart';
import '../repositories/recipe_repository.dart';

part 'saved.g.dart';

@riverpod
Set<String> savedRecipeIds(Ref ref) {
  final savedRecipesAsync = ref.watch(savedRecipesProvider);
  return savedRecipesAsync.when<Set<String>>(
    data: (List<Recipe> recipes) => recipes.where((r) => r.isSaved == true).map((r) => r.id).toSet(),
    loading: () => {},
    error: (err, stack) => {},
  );
}

@riverpod
bool recipeIsSaved(Ref ref, String recipeId) {
  return ref.watch(savedRecipeIdsProvider).contains(recipeId);
}

@Riverpod(keepAlive: true)
class SavedRecipesFilter extends _$SavedRecipesFilter {
  @override
  RecipeFilter build() => const RecipeFilter();

  void update(RecipeFilter filter) => state = filter;
}

@Riverpod(keepAlive: true)
class SavedRecipes extends _$SavedRecipes with PagedNotifierMixin<Recipe> {
  static const List<RecipePreload> _preload = [.images, .collections, .saved, .publisher];

  @override
  Future<List<Recipe>> build() async {
    resetPagination();
    final filter = ref.read(savedRecipesFilterProvider);
    final result = await ref
        .read(recipeRepositoryProvider)
        .findAll(
          preload: _preload,
          filter: filter,
          limit: pageSize,
          offset: 0,
        );
    return result.data;
  }

  /// Removes a recipe from the cached list in-place, avoiding a reload flash.
  void remove(String recipeId) {
    state = state.whenData((list) => list.where((r) => r.id != recipeId).toList());
  }

  Future<void> loadMore() => loadNextPage((offset, limit) {
    final filter = ref.read(savedRecipesFilterProvider);
    return ref
        .read(recipeRepositoryProvider)
        .findAll(
          preload: _preload,
          filter: filter,
          offset: offset,
          limit: limit,
        );
  });
}

@Riverpod(keepAlive: true)
class SavedCollections extends _$SavedCollections with PagedNotifierMixin<Collection> {
  static const List<CollectionPreload> _preload = [.total_recipes, .last3_recipes];

  @override
  Future<List<Collection>> build() async {
    resetPagination();
    final result = await ref
        .read(collectionRepositoryProvider)
        .findAll(
          preload: _preload,
          limit: pageSize,
          offset: 0,
        );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage(
    (offset, limit) => ref
        .read(collectionRepositoryProvider)
        .findAll(
          preload: _preload,
          offset: offset,
          limit: limit,
        ),
  );

  Future<void> create(String name) async {
    await ref.read(collectionRepositoryProvider).create(name);
    ref.invalidateSelf();
  }
}
