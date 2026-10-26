import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/components/error_state.dart';
import '../../shared/components/recipes/recipes_grid.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_filter.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';

/// The saved recipes grid as a sliver, handling loading, error, empty, and
/// populated states.
class SavedRecipesSliver extends StatelessWidget {
  final AsyncValue<List<Recipe>> recipesAsync;
  final RecipeFilter filter;
  final VoidCallback onClearFilter;
  final VoidCallback onRetry;

  const SavedRecipesSliver({
    super.key,
    required this.recipesAsync,
    required this.filter,
    required this.onClearFilter,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return recipesAsync.when(
      data: (recipes) {
        if (recipes.isNotEmpty) return SliverRecipesGrid(recipes);
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: filter.isEmpty ? Icons.menu_book_outlined : Icons.search_off,
              title: filter.isEmpty ? context.l10n.recipesNoRecipesYet : context.l10n.feedFilterEmptyTitle,
              subtitle: filter.isEmpty ? null : context.l10n.feedFilterEmptySubtitle,
              action: filter.isEmpty
                  ? TextButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.refresh),
                    )
                  : TextButton.icon(
                      onPressed: onClearFilter,
                      icon: const Icon(Icons.filter_alt_off),
                      label: Text(context.l10n.feedClearFilters),
                    ),
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: ErrorState(
            message: context.errorMessage(error),
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}
