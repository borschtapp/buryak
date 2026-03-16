import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/hooks.dart';
import '../../shared/widgets/error_view.dart';
import 'notifier_saved.dart';
import 'dialog_create_collection.dart';
import 'view_saved_tabs.dart';
import 'dialog_import_recipe.dart';

class SavedScreen extends HookConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    useListenable(tabController);

    final isLoadingMoreRecipes = useState(false);
    final isLoadingMoreCollections = useState(false);

    useFab(ref, _buildFab(context, ref, tabController.index));

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
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              recipesAsync.when(
                data: (recipes) => SavedRecipesTab(
                  recipes: recipes,
                  onLoadMore: handleLoadMoreRecipes,
                  isLoadingMore: isLoadingMoreRecipes.value,
                  hasMore: recipesNotifier.hasMore,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorView(message: err.toString()),
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
                error: (err, stack) => ErrorView(message: err.toString()),
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
