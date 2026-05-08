import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/recipes/dialog_import.dart';
import '../../shared/components/recipes/recipe_search_bar.dart';
import '../../shared/hooks.dart';
import '../../shared/layouts/searchable_grid_scaffold.dart';
import '../../shared/providers/saved.dart';
import 'dialog_create_collection.dart';
import 'section_saved_tabs.dart';

class SavedScreen extends HookConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    useListenable(tabController);

    final isFiltersOpen = useState(false);
    final fab = useMemoized(
      () => _buildFab(context, ref, tabController.index),
      [tabController.index],
    );

    useFab(ref, isFiltersOpen.value ? null : fab);

    final recipesAsync = ref.watch(savedRecipesProvider);
    final collectionsAsync = ref.watch(savedCollectionsProvider);
    final recipesNotifier = ref.read(savedRecipesProvider.notifier);
    final collectionsNotifier = ref.read(savedCollectionsProvider.notifier);

    final filter = ref.read(savedRecipesFilterProvider);

    return SearchableGridScaffold(
      maxWidth: 1440,
      searchBar: tabController.index == 0
          ? RecipeSearchBar(
              filter: filter,
              scope: 'saved',
              onChanged: (f) {
                ref.read(savedRecipesFilterProvider.notifier).update(f);
                ref.invalidate(savedRecipesProvider);
              },
              onFiltersOpenChanged: (isOpen) => isFiltersOpen.value = isOpen,
            )
          : null,
      topWidget: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'Recipes'),
          Tab(text: 'Cookbooks'),
        ],
      ),
      child: TabBarView(
        controller: tabController,
        children: [
          SavedTabs(
            value: recipesAsync,
            filter: filter,
            onLoadMore: recipesNotifier.loadMore,
            isLoadingMore: recipesNotifier.isLoadingMore,
            hasMore: recipesNotifier.hasMore,
            onRefresh: () async => ref.invalidate(savedRecipesProvider),
          ),
          SavedCookbooksTab(
            value: collectionsAsync,
            onCreateCollection: () => showCreateCollectionDialog(context, ref),
            onLoadMore: collectionsNotifier.loadMore,
            isLoadingMore: collectionsNotifier.isLoadingMore,
            hasMore: collectionsNotifier.hasMore,
            onRefresh: () async => ref.invalidate(savedCollectionsProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref, int tabIndex) {
    if (tabIndex == 0) {
      return FloatingActionButton(
        heroTag: 'saved_import_fab',
        onPressed: () => showImportDialog(context, ref),
        child: const Icon(Icons.add),
      );
    } else {
      return FloatingActionButton(
        heroTag: 'saved_cookbook_fab',
        onPressed: () => showCreateCollectionDialog(context, ref),
        child: const Icon(Icons.add),
      );
    }
  }
}
