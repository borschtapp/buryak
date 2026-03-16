import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/paged_notifier_mixin.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/recipes/view_recipes_grid.dart';

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
          preload: 'images,saved,collections,publisher',
          limit: pageSize,
          offset: 0,
        );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage(
    (offset, limit) => ref
        .read(collectionRepositoryProvider)
        .getRecipes(
          id,
          preload: 'images,saved,collections,publisher',
          offset: offset,
          limit: limit,
        ),
  );
}

class CollectionScreen extends HookConsumerWidget {
  final String collectionId;

  const CollectionScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingMore = useState(false);

    final recipesAsync = ref.watch(collectionRecipesProvider(collectionId));
    final notifier = ref.read(collectionRecipesProvider(collectionId).notifier);

    Future<void> handleLoadMore() async {
      if (isLoadingMore.value || !notifier.hasMore) return;
      isLoadingMore.value = true;
      try {
        await notifier.loadMore();
      } finally {
        if (context.mounted) isLoadingMore.value = false;
      }
    }

    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return const Center(child: Text('No recipes in this cookbook yet.'));
        }
        return RecipesGridView(
          recipes,
          onLoadMore: handleLoadMore,
          isLoadingMore: isLoadingMore.value,
          hasMore: notifier.hasMore,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(collectionRecipesProvider(collectionId)),
      ),
    );
  }
}
