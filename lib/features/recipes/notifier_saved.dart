import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/paged_notifier_mixin.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/repositories/recipe_repository.dart';

part 'notifier_saved.g.dart';

@Riverpod(keepAlive: true)
class SavedRecipesFilter extends _$SavedRecipesFilter {
  @override
  RecipeFilter build() => const RecipeFilter();

  void update(RecipeFilter filter) => state = filter;
}

@Riverpod(keepAlive: true)
class SavedRecipes extends _$SavedRecipes with PagedNotifierMixin<Recipe> {
  static const _preload = 'images,collections,saved,publisher';

  @override
  Future<List<Recipe>> build() async {
    resetPagination();
    final filter = ref.read(savedRecipesFilterProvider);
    final result = await ref.read(recipeRepositoryProvider).findAll(
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
    return ref.read(recipeRepositoryProvider).findAll(
      preload: _preload,
      filter: filter,
      offset: offset,
      limit: limit,
    );
  });
}

@Riverpod(keepAlive: true)
class SavedCollections extends _$SavedCollections with PagedNotifierMixin<Collection> {
  @override
  Future<List<Collection>> build() async {
    resetPagination();
    final result = await ref
        .read(collectionRepositoryProvider)
        .findAll(
          preload: 'recipes:5,recipes.images,total_recipes',
          limit: pageSize,
          offset: 0,
        );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage(
    (offset, limit) => ref
        .read(collectionRepositoryProvider)
        .findAll(
          preload: 'recipes:5,recipes.images,total_recipes',
          offset: offset,
          limit: limit,
        ),
  );

  Future<void> create(String name) async {
    await ref.read(collectionRepositoryProvider).create(name);
    ref.invalidateSelf();
  }
}
