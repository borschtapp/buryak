import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/empty_state.dart';
import '../../shared/components/recipes/recipes_grid.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/models/recipe.dart';
import '../../shared/providers/saved.dart';
import '../../shared/util/extensions.dart';

class CollectionScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = collectionRecipesProvider(collectionId);
    final recipesAsync = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return AppListScaffold<List<Recipe>>(
      value: recipesAsync,
      onRefresh: () async => ref.invalidate(provider),
      onLoadMore: notifier.loadMore,
      isLoadingMore: notifier.isLoadingMore,
      hasMore: notifier.hasMore,
      isEmpty: (data) => data.isEmpty,
      emptyState: EmptyState(
        icon: Icons.auto_stories_outlined,
        title: context.l10n.collectionEmptyTitle,
        subtitle: context.l10n.collectionEmptySubtitle,
      ),
      data: RecipesGrid.new,
    );
  }
}
