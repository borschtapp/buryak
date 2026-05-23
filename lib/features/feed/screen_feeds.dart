import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/dismissible_tile.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/components/recipes/dialog_import.dart';
import '../../shared/hooks.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/models/feed.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'notifier_feed_list.dart';
import 'section_feed_card.dart';

class FeedsScreen extends HookConsumerWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedsAsync = ref.watch(feedListProvider);

    useFab(
      ref,
      FloatingActionButton(
        heroTag: 'feeds_add_fab',
        onPressed: () => showImportDialog(context, ref, isFeedOnly: true),
        child: const Icon(Icons.add),
      ),
    );

    return AppListScaffold<List<Feed>>(
      value: feedsAsync,
      onRefresh: () async => ref.invalidate(feedListProvider),
      isEmpty: (data) => data.isEmpty,
      emptyState: EmptyState(
        icon: Icons.rss_feed_outlined,
        title: 'No feeds yet',
        subtitle: 'Add a feed URL to start discovering recipes from your favourite food blogs.',
        action: FilledButton.icon(
          onPressed: () => showImportDialog(context, ref, isFeedOnly: true),
          icon: const Icon(Icons.add),
          label: const Text('Add Feed'),
        ),
      ),
      data: (feeds) => ListView.separated(
        padding: const EdgeInsets.only(top: UIConstants.paddingSmall, bottom: 80),
        itemCount: feeds.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final feed = feeds[index];
          return DismissibleTile(
            key: ValueKey(feed.id),
            label: feed.name,
            onConfirmDelete: () => showConfirmDialog(
              context,
              title: 'Remove Feed',
              content: 'Remove "${feed.name}" and all its imported recipes from your feed?',
              confirmLabel: 'Remove',
              destructive: true,
            ),
            onDelete: () => _deleteFeed(ref, context, feed),
            child: FeedCard(feed: feed),
          );
        },
      ),
    );
  }

  Future<void> _deleteFeed(
    WidgetRef ref,
    BuildContext context,
    Feed feed,
  ) async {
    try {
      await ref.read(feedListProvider.notifier).removeFeed(feed);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${feed.name}" removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await ref.read(feedListProvider.notifier).restoreFeed(feed);
                } catch (e) {
                  if (context.mounted) ref.handleException(e);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) ref.handleException(e);
    }
  }
}
