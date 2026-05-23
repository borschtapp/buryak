import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/components/recipes/dialog_import.dart';
import '../../shared/components/recipes/recipe_search_bar.dart';
import '../../shared/components/recipes/recipes_grid.dart';
import '../../shared/hooks.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/layouts/searchable_grid_scaffold.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/util/ui_constants.dart';
import 'notifier_feed.dart';

class FeedScreen extends HookConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFiltersOpen = useState(false);
    final fab = useMemoized(
      () => FloatingActionButton(
        heroTag: 'feed_add_fab',
        onPressed: () => showImportDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      [],
    );

    useFab(ref, isFiltersOpen.value ? null : fab);

    final streamAsync = ref.watch(feedStreamProvider);
    final notifier = ref.read(feedStreamProvider.notifier);
    final filter = ref.watch(feedFilterProvider);

    return SearchableGridScaffold(
      maxWidth: UIConstants.defaultMaxWidth,
      searchBar: RecipeSearchBar(
        filter: filter,
        scope: 'feeds',
        onChanged: (newFilter) {
          ref.read(feedFilterProvider.notifier).update(newFilter);
        },
        onFiltersOpenChanged: (isOpen) => isFiltersOpen.value = isOpen,
      ),
      child: AppListScaffold<List<Recipe>>(
        value: streamAsync,
        onRefresh: () async => ref.invalidate(feedStreamProvider),
        onLoadMore: notifier.loadMore,
        isLoadingMore: notifier.isLoadingMore,
        hasMore: notifier.hasMore,
        isEmpty: (results) => results.isEmpty,
        emptyState: EmptyState(
          icon: Icons.explore_outlined,
          title: filter.isEmpty ? 'No recipes found' : 'No results',
          subtitle: filter.isEmpty ? 'Try adding a new feed or standardizing existing ones.' : 'Try adjusting your search or filters.',
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
        ),
        data: (results) => RecipesGrid(
          results,
          onLoadMore: notifier.loadMore,
          isLoadingMore: notifier.isLoadingMore,
          hasMore: notifier.hasMore,
        ),
      ),
    );
  }
}
