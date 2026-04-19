import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/components/error_state.dart';
import '../../shared/hooks.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/providers/paged_notifier_mixin.dart';
import '../../shared/providers/user.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/repositories/recipe_repository.dart';
import '../recipes/section_recipe_search_bar.dart';
import '../recipes/section_recipes_grid.dart';
import 'dialog_add_feed.dart';

part 'screen_feed.g.dart';

@Riverpod(keepAlive: true)
class FeedFilter extends _$FeedFilter {
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
class FeedStream extends _$FeedStream with PagedNotifierMixin<Recipe> {
  static const List<RecipePreload> _preload = [.images, .author, .publisher, .collections, .saved];

  @override
  Future<List<Recipe>> build() async {
    resetPagination();
    // Watch authProvider so build() re-runs on login and logout, preventing
    // stale data from persisting across account switches.
    final user = ref.watch(authProvider);
    if (user == null) return [];

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

class FeedScreen extends HookConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFiltersOpen = useState(false);
    final fab = useMemoized(
      () => FloatingActionButton(
        heroTag: 'feed_add_fab',
        onPressed: () => showAddFeedDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      [],
    );

    useFab(ref, isFiltersOpen.value ? null : fab);

    final streamAsync = ref.watch(feedStreamProvider);
    final notifier = ref.read(feedStreamProvider.notifier);
    final filter = ref.watch(feedFilterProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: RecipeSearchBar(
            filter: filter,
            scope: 'feeds',
            onChanged: (newFilter) {
              ref.read(feedFilterProvider.notifier).update(newFilter);
            },
            onFiltersOpenChanged: (isOpen) => isFiltersOpen.value = isOpen,
          ),
        ),
        Expanded(
          child: streamAsync.when(
            data: (results) => results.isEmpty
                ? EmptyState(
                    icon: Icons.explore_outlined,
                    title: filter.isEmpty ? 'No recipes found' : 'No results',
                    subtitle: filter.isEmpty
                        ? 'Try adding a new feed or standardizing existing ones.'
                        : 'Try adjusting your search or filters.',
                    action: filter.isEmpty
                        ? TextButton.icon(
                            onPressed: () => ref.invalidate(feedStreamProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          )
                        : TextButton.icon(
                            onPressed: () {
                              ref.read(feedFilterProvider.notifier).update(const RecipeFilter());
                            },
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Clear filters'),
                          ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(feedStreamProvider),
                    child: RecipesGrid(
                      results,
                      onLoadMore: notifier.loadMore,
                      isLoadingMore: notifier.isLoadingMore,
                      hasMore: notifier.hasMore,
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(feedStreamProvider),
            ),
          ),
        ),
      ],
    );
  }
}
