import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/providers/user.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/repositories/recipe_repository.dart';

part 'notifier_feed.g.dart';

@Riverpod(keepAlive: true)
class FeedFilter extends _$FeedFilter {
  @override
  RecipeFilter build() {
    ref.watch(sessionProvider);
    return const RecipeFilter();
  }

  void update(RecipeFilter filter) => state = filter;
}

@Riverpod(keepAlive: true)
class FeedStream extends _$FeedStream with PagedNotifierMixin<Recipe> {
  static const List<RecipePreload> _preload = [.images, .author, .publisher, .collections, .saved];

  @override
  Future<List<Recipe>> build() async {
    resetPagination();
    ref.watchSession();
    final filter = ref.watch(feedFilterProvider);
    // Use ref.read (not ref.watch) for the repository — consistent with
    // loadMore() and avoids spurious rebuilds from a stable provider.
    final result = await ref
        .read(feedRepositoryProvider)
        .stream(
          preload: _preload,
          filter: filter,
          limit: limit,
          offset: 0,
        );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage((offset, limit) {
    final filter = ref.read(feedFilterProvider);
    return ref
        .read(feedRepositoryProvider)
        .stream(
          preload: _preload,
          filter: filter,
          offset: offset,
          limit: limit,
        );
  });
}
