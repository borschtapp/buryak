import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/hooks.dart';
import '../../shared/models/recipe.dart';
import '../../shared/paged_notifier_mixin.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/widgets/recipes/view_recipes_grid.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/text_input_dialog.dart';

part 'screen_explore.g.dart';

@Riverpod(keepAlive: true)
class FeedStream extends _$FeedStream with PagedNotifierMixin<Recipe> {
  @override
  Future<List<Recipe>> build() async {
    resetPagination();
    final result = await ref.read(feedRepositoryProvider).stream(
      preload: 'images,author,publisher,collections,saved',
      limit: pageSize,
      offset: 0,
    );
    return result.data;
  }

  Future<void> loadMore() => loadNextPage(
    (offset, limit) => ref.read(feedRepositoryProvider).stream(
      preload: 'images,author,publisher,collections,saved',
      offset: offset,
      limit: limit,
    ),
  );
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

    useFab(ref, 
      FloatingActionButton(
        heroTag: 'explore_add_fab',
        onPressed: () => showAddFeedDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );

    final streamAsync = ref.watch(feedStreamProvider);
    final notifier = ref.read(feedStreamProvider.notifier);

    Future<void> handleLoadMore() async {
      if (isLoadingMore.value || !notifier.hasMore) return;
      isLoadingMore.value = true;
      try {
        await notifier.loadMore();
      } finally {
        if (context.mounted) isLoadingMore.value = false;
      }
    }

    return streamAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return EmptyStateView(
            icon: Icons.explore_outlined,
            title: 'No recipes found',
            subtitle: 'Try adding a new feed or standardizing existing ones.',
            action: TextButton.icon(
              onPressed: () => ref.invalidate(feedStreamProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(feedStreamProvider),
          child: RecipesGridView(
            results,
            onLoadMore: handleLoadMore,
            isLoadingMore: isLoadingMore.value,
            hasMore: notifier.hasMore,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => ErrorView(
        message: err.toString(),
        onRetry: () => ref.invalidate(feedStreamProvider),
      ),
    );
  }
}
