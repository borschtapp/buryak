import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/error_state.dart';
import '../../shared/hooks.dart';
import '../../shared/providers/saved.dart';
import '../../shared/providers/shell.dart';
import 'dialog_create_collection.dart';
import 'dialog_import_recipe.dart';
import 'section_recipe_search_bar.dart';
import 'section_saved_tabs.dart';

class SavedScreen extends HookConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    useListenable(tabController);

    final isLoadingMoreRecipes = useState(false);
    final isLoadingMoreCollections = useState(false);

    final fab = useMemoized(
      () => _buildFab(context, ref, tabController.index),
      [tabController.index],
    );

    useFab(ref, fab);

    final recipesAsync = ref.watch(savedRecipesProvider);
    final collectionsAsync = ref.watch(savedCollectionsProvider);
    final recipesNotifier = ref.read(savedRecipesProvider.notifier);
    final collectionsNotifier = ref.read(savedCollectionsProvider.notifier);

    Future<void> handleLoadMoreRecipes() async {
      if (isLoadingMoreRecipes.value || !recipesNotifier.hasMore) return;
      isLoadingMoreRecipes.value = true;
      try {
        await recipesNotifier.loadMore();
      } finally {
        if (context.mounted) isLoadingMoreRecipes.value = false;
      }
    }

    Future<void> handleLoadMoreCollections() async {
      if (isLoadingMoreCollections.value || !collectionsNotifier.hasMore) return;
      isLoadingMoreCollections.value = true;
      try {
        await collectionsNotifier.loadMore();
      } finally {
        if (context.mounted) isLoadingMoreCollections.value = false;
      }
    }

    final filter = ref.read(savedRecipesFilterProvider);

    return Column(
      children: [
        TabBar(
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Recipes'),
            Tab(text: 'Cookbooks'),
          ],
        ),
        if (tabController.index == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: RecipeSearchBar(
              filter: filter,
              onChanged: (f) {
                ref.read(savedRecipesFilterProvider.notifier).update(f);
                ref.invalidate(savedRecipesProvider);
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
          child: TabBarView(
            controller: tabController,
            children: [
              recipesAsync.when(
                data: (recipes) => SavedTabs(
                  recipes: recipes,
                  filter: filter,
                  onLoadMore: handleLoadMoreRecipes,
                  isLoadingMore: isLoadingMoreRecipes.value,
                  hasMore: recipesNotifier.hasMore,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorState(message: err.toString()),
              ),
              collectionsAsync.when(
                data: (collections) => SavedCookbooksTab(
                  collections: collections,
                  onCreateCollection: () => showCreateCollectionDialog(context, ref),
                  onLoadMore: handleLoadMoreCollections,
                  isLoadingMore: isLoadingMoreCollections.value,
                  hasMore: collectionsNotifier.hasMore,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorState(message: err.toString()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref, int tabIndex) {
    if (tabIndex == 0) {
      return FloatingActionButton(
        heroTag: 'saved_import_fab',
        onPressed: () => showImportRecipeDialog(context, ref),
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
