import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/hooks.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/paged_notifier_mixin.dart';
import '../../shared/providers/shell.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/recipe_search_bar.dart';
import '../../shared/widgets/recipes/view_recipes_grid.dart';
import '../../shared/widgets/text_input_dialog.dart';

part 'screen_explore.g.dart';

@Riverpod(keepAlive: true)
class ExploreFilter extends _$ExploreFilter {
  @override
  RecipeFilter build() => const RecipeFilter();

  void update(RecipeFilter filter) => state = filter;
}

@Riverpod(keepAlive: true)
class FeedStream extends _$FeedStream with PagedNotifierMixin<Recipe> {
  static const _preload = 'images,author,publisher,collections,saved';

  @override
  Future<List<Recipe>> build() async {
    resetPagination();
    final filter = ref.read(exploreFilterProvider);
    final result = await ref
        .read(feedRepositoryProvider)
        .stream(
          preload: _preload,
          filter: filter,
          limit: pageSize,
          offset: 0,
        );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage((offset, limit) {
    final filter = ref.read(exploreFilterProvider);
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

void showAddFeedDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => TextInputDialog(
      title: 'Add New Feed',
      hintText: 'Feed URL (RSS/Atom)',
      helperText: 'Enter the URL of the recipe feed',
      submitLabel: 'Add',
      validator: (value) => value.isEmpty ? 'URL cannot be empty' : null,
      onSubmit: (url, ctx) async {
        await ref.read(feedRepositoryProvider).subscribe(url);
        ref.invalidate(feedStreamProvider);
        if (ctx.mounted) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Feed added! It might take a few minutes for recipes to be processed.'),
            ),
          );
        }
      },
    ),
  );
}

class ExploreScreen extends HookConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingMore = useState(false);

    final fab = useMemoized(
      () => FloatingActionButton(
        heroTag: 'explore_add_fab',
        onPressed: () => showAddFeedDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      [],
    );

    useFab(ref, fab);

    final streamAsync = ref.watch(feedStreamProvider);
    final notifier = ref.read(feedStreamProvider.notifier);
    final filter = ref.read(exploreFilterProvider);

    Future<void> handleLoadMore() async {
      if (isLoadingMore.value || !notifier.hasMore) return;
      isLoadingMore.value = true;
      try {
        await notifier.loadMore();
      } finally {
        if (context.mounted) isLoadingMore.value = false;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: RecipeSearchBar(
            filter: filter,
            onChanged: (newFilter) {
              ref.read(exploreFilterProvider.notifier).update(newFilter);
              ref.invalidate(feedStreamProvider);
            },
            onFiltersOpenChanged: (isOpen) {
              if (isOpen) {
                ref.read(shellFabProvider.notifier).update(null);
              } else {
                ref.read(shellFabProvider.notifier).update(fab);
              }
            },
          ),
        ),
        Expanded(
          child: streamAsync.when(
            data: (results) => results.isEmpty
                ? EmptyStateView(
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
                              ref.read(exploreFilterProvider.notifier).update(const RecipeFilter());
                              ref.invalidate(feedStreamProvider);
                            },
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Clear filters'),
                          ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(feedStreamProvider),
                    child: RecipesGridView(
                      results,
                      onLoadMore: handleLoadMore,
                      isLoadingMore: isLoadingMore.value,
                      hasMore: notifier.hasMore,
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => ErrorView(
              message: err.toString(),
              onRetry: () => ref.invalidate(feedStreamProvider),
            ),
          ),
        ),
      ],
    );
  }
}
