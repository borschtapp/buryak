import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_import.dart';
import '../../shared/components/recipes/recipe_search_bar.dart';
import '../../shared/hooks.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/layouts/searchable_grid_scaffold.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/providers/saved.dart';
import '../../shared/route_names.dart';
import 'dialog_create_collection.dart';
import 'section_saved_cookbooks_carousel.dart';
import 'section_saved_recipes_header.dart';
import 'section_saved_recipes_slivers.dart';

class SavedScreen extends HookConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFiltersOpen = useState(false);
    final fab = useMemoized(
      () => FloatingActionButton(
        heroTag: 'saved_import_fab',
        onPressed: () => showImportDialog(context),
        child: const Icon(Icons.add),
      ),
    );

    useFab(ref, isFiltersOpen.value ? null : fab);

    final recipesAsync = ref.watch(savedRecipesProvider);
    final recipesNotifier = ref.read(savedRecipesProvider.notifier);
    final filter = ref.watch(savedRecipesFilterProvider);

    void updateFilter(RecipeFilter newFilter) => ref.read(savedRecipesFilterProvider.notifier).update(newFilter);
    void clearFilter() => updateFilter(const RecipeFilter());

    return SearchableGridScaffold(
      searchBar: RecipeSearchBar(
        filter: filter,
        scope: 'saved',
        onChanged: updateFilter,
        onFiltersOpenChanged: (isOpen) => isFiltersOpen.value = isOpen,
      ),
      child: PagedRefreshScope(
        onRefresh: () async {
          ref.invalidate(savedRecipesProvider);
          ref.invalidate(savedCollectionsProvider);
        },
        onLoadMore: recipesNotifier.loadMore,
        isLoadingMore: recipesNotifier.isLoadingMore,
        hasMore: recipesNotifier.hasMore,
        child: CustomScrollView(
          slivers: [
            if (filter.isEmpty)
              SliverToBoxAdapter(
                child: SavedCookbooksCarousel(
                  onCreateCookbook: () => showCreateCollectionDialog(context),
                  onSeeAll: () => context.pushNamed(RouteNames.cookbooks),
                ),
              ),
            SliverToBoxAdapter(
              child: SavedRecipesHeader(
                filter: filter,
                onSortChanged: (sort, order) => updateFilter(filter.copyWith(sort: sort, order: order)),
                onClearFilter: clearFilter,
              ),
            ),
            SavedRecipesSliver(
              recipesAsync: recipesAsync,
              filter: filter,
              onClearFilter: clearFilter,
              onRetry: () => ref.invalidate(savedRecipesProvider),
            ),
            if (recipesNotifier.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}
