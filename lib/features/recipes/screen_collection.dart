import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/components/error_state.dart';
import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/repositories/collection_repository.dart';
import 'section_recipes_grid.dart';

part 'screen_collection.g.dart';

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

class CollectionScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(collectionRecipesProvider(collectionId));
    final notifier = ref.read(collectionRecipesProvider(collectionId).notifier);

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes in this cookbook yet.'));
        }
        return RecipesGrid(
          recipes,
          onLoadMore: notifier.loadMore,
          isLoadingMore: notifier.isLoadingMore,
          hasMore: notifier.hasMore,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(collectionRecipesProvider(collectionId)),
      ),
    );
  }
}
