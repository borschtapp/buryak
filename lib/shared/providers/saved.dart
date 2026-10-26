import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/collection.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../models/recipe_saved_user.dart';
import '../repositories/collection_repository.dart';
import '../repositories/recipe_repository.dart';
import 'importer.dart';
import 'paged_notifier_mixin.dart';
import 'user.dart';

part 'saved.g.dart';

// Run with `tsx.get(savedCollectionsProvider.notifier)`.
final createCollectionMutation = Mutation<void>(label: 'createCollection');
final updateRecipeCollectionsMutation = Mutation<void>(label: 'updateRecipeCollections');

/// Likes the signed-in user toggled since their recipes were fetched, by recipe ID.
///
/// A recipe's `saved_by` is only as fresh as the list it came from; these win over it
/// (see [WatchRecipeSaved.watchIsSaved]).
@Riverpod(keepAlive: true)
class RecipeSaveToggles extends _$RecipeSaveToggles {
  @override
  Map<String, bool> build() {
    ref.watch(sessionProvider);
    return const {};
  }

  /// Likes or unlikes [recipeId], showing the change before the server confirms it.
  Future<void> toggle(String recipeId, {required bool isSaved}) async {
    state = {...state, recipeId: !isSaved};
    final repo = ref.read(recipeRepositoryProvider);
    try {
      if (isSaved) {
        final userId = ref.read(sessionProvider)?.userId;
        if (userId != null && ref.exists(savedRecipesProvider)) {
          ref.read(savedRecipesProvider.notifier).removeLike(recipeId, userId);
        }
        await repo.unsave(recipeId);
      } else {
        await repo.save(recipeId);
        ref.invalidate(savedRecipesProvider);
      }
    } catch (_) {
      state = {...state, recipeId: isSaved};
      ref.invalidate(savedRecipesProvider);
      rethrow;
    }
  }
}

extension WatchRecipeSaved on WidgetRef {
  /// Whether the signed-in user liked [recipe]. Likes are per user, so one by
  /// another household member doesn't count.
  bool watchIsSaved(Recipe recipe) {
    final toggled = watch(recipeSaveTogglesProvider.select((toggles) => toggles[recipe.id]));
    if (toggled != null) return toggled;
    final userId = watch(sessionProvider)?.userId;
    return recipe.savedBy?.any((user) => user.id == userId) ?? false;
  }

  /// The other household members who liked [recipe]; the user's own like is the heart.
  List<RecipeSavedUser> watchLikedByOthers(Recipe recipe) {
    final userId = watch(sessionProvider)?.userId;
    return [...?recipe.savedBy?.where((user) => user.id != userId)];
  }
}

@Riverpod(keepAlive: true)
class SavedRecipesFilter extends _$SavedRecipesFilter {
  @override
  RecipeFilter build() {
    ref.watch(sessionProvider);
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
    ref.watchSession();
    ref.watch(importTriggerProvider);
    final filter = ref.read(savedRecipesFilterProvider);
    final result = await ref
        .read(recipeRepositoryProvider)
        .findAll(
          preload: _preload,
          filter: filter,
          scope: 'saved',
          limit: limit,
          offset: 0,
        );
    return result.data;
  }

  /// Drops [userId]'s like from the cached list in place, avoiding a reload flash.
  ///
  /// Saved lists the whole household's likes, so the recipe stays while someone else
  /// still likes it.
  void removeLike(String recipeId, String userId) {
    state = state.whenData(
      (list) => [
        for (final recipe in list)
          if (recipe.id != recipeId) recipe else ?_withoutLike(recipe, userId),
      ],
    );
  }

  /// [recipe] without [userId]'s like, or `null` when nobody else likes it.
  static Recipe? _withoutLike(Recipe recipe, String userId) {
    final others = [...?recipe.savedBy?.where((user) => user.id != userId)];
    return others.isEmpty ? null : recipe.copyWith(savedBy: others);
  }

  Future<void> loadMore() => loadNextPage((offset, limit) {
    final filter = ref.read(savedRecipesFilterProvider);
    return ref
        .read(recipeRepositoryProvider)
        .findAll(
          preload: _preload,
          filter: filter,
          scope: 'saved',
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
    ref.watchSession();
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

  /// Adds [recipeId] to the collections in [add] and removes it from those in [remove].
  Future<void> updateRecipeCollections(String recipeId, {required Set<String> add, required Set<String> remove}) async {
    final repo = ref.read(collectionRepositoryProvider);
    try {
      // Waits for every change before throwing, so the reload sees all that succeeded.
      await Future.wait([
        ...add.map((id) => repo.addRecipe(id, recipeId)),
        ...remove.map((id) => repo.removeRecipe(id, recipeId)),
      ]);
    } finally {
      ref.invalidate(collectionRecipesProvider);
      // Last step: rebuilding replaces this notifier, so nothing after it may use ref or state.
      ref.invalidateSelf();
    }
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
