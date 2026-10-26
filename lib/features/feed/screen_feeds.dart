import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/dismissible_tile.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/components/dialog_import.dart';
import '../../shared/hooks.dart';
import '../../shared/layouts/app_list_scaffold.dart';
import '../../shared/models/feed.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'notifier_feed_list.dart';
import 'section_feed_card.dart';

class FeedsScreen extends HookConsumerWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedsAsync = ref.watch(feedListProvider);

    final fab = useMemoized(
      () => FloatingActionButton(
        heroTag: 'feeds_add_fab',
        onPressed: () => showImportDialog(context, isFeedOnly: true),
        child: const Icon(Icons.add),
      ),
    );
    useFab(ref, fab);

    return AppListScaffold<List<Feed>>(
      value: feedsAsync,
      onRefresh: () async => ref.invalidate(feedListProvider),
      isEmpty: (data) => data.isEmpty,
      emptyState: EmptyState(
        icon: Icons.rss_feed_outlined,
        title: context.l10n.feedsEmptyTitle,
        subtitle: context.l10n.feedsEmptySubtitle,
        action: FilledButton.icon(
          onPressed: () => showImportDialog(context, isFeedOnly: true),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.importAddFeed),
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
              title: context.l10n.feedsRemoveFeedTitle,
              content: context.l10n.feedsRemoveFeedContent(feed.name),
              confirmLabel: context.l10n.feedsRemoveFeedConfirm,
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
    final removed = await removeFeedMutation.tryRun(
      ref,
      (tsx) => tsx.get(feedListProvider.notifier).removeFeed(feed),
    );

    if (removed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.feedsFeedRemoved(feed.name)),
          action: SnackBarAction(
            label: context.l10n.feedsUndo,
            onPressed: () => restoreFeedMutation.tryRun(
              ref,
              (tsx) => tsx.get(feedListProvider.notifier).restoreFeed(feed),
            ),
          ),
        ),
      );
    }
  }
}
