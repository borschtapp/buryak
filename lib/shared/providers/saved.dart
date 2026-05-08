import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/collection.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../repositories/collection_repository.dart';
import '../repositories/recipe_repository.dart';
import 'paged_notifier_mixin.dart';
import 'user.dart';

part 'saved.g.dart';

@riverpod
Set<String> savedRecipeIds(Ref ref) {
  final recipes = ref.watch(savedRecipesProvider).value ?? [];
  return recipes.map((r) => r.id).toSet();
}

@riverpod
bool recipeIsSaved(Ref ref, String recipeId) {
  return ref.watch(savedRecipeIdsProvider).contains(recipeId);
}

@Riverpod(keepAlive: true)
class SavedRecipesFilter extends _$SavedRecipesFilter {
  @override
  RecipeFilter build() {
    ref.listen(authProvider, (_, next) {
      if (next == null) state = const RecipeFilter();
    });
    return const RecipeFilter();
  }

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
          limit: limit,
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
          limit: limit,
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

@riverpod
class SavedRecipeState extends _$SavedRecipeState {
  @override
  ({bool isSaved, Future<void> Function() toggle}) build(String recipeId) {
    final isSaved = ref.watch(recipeIsSavedProvider(recipeId));
    return (
      isSaved: isSaved,
      toggle: () async {
        final currentIsSaved = ref.read(recipeIsSavedProvider(recipeId));
        if (!currentIsSaved) {
          await ref.read(recipeRepositoryProvider).save(recipeId);
          ref.invalidate(savedRecipesProvider);
        } else {
          ref.read(savedRecipesProvider.notifier).remove(recipeId);
          try {
            await ref.read(recipeRepositoryProvider).unsave(recipeId);
          } catch (e) {
            ref.invalidate(savedRecipesProvider);
            rethrow;
          }
        }
      },
    );
  }
}

@riverpod
Future<Collection> collectionDetails(Ref ref, String id) {
  return ref.read(collectionRepositoryProvider).findOne(id);
}

@riverpod
class CollectionRecipes extends _$CollectionRecipes with PagedNotifierMixin<Recipe> {
  @override
  Future<List<Recipe>> build(String id) async {
    resetPagination();
    final result = await ref
        .read(collectionRepositoryProvider)
        .getRecipes(
          id,
          preload: [.images, .saved, .collections, .publisher],
          limit: limit,
          offset: 0,
        );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage(
    (offset, limit) => ref
        .read(collectionRepositoryProvider)
        .getRecipes(
          id,
          preload: [.images, .saved, .collections, .publisher],
          offset: offset,
          limit: limit,
        ),
  );
}
