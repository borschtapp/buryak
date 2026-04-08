import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/empty_state.dart';
import '../../shared/components/error_state.dart';
import '../../shared/hooks.dart';
import '../../shared/models/feed.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'dialog_add_feed.dart';
import 'feed_card.dart';
import 'notifier_feed_list.dart';

class FeedsScreen extends HookConsumerWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedsAsync = ref.watch(feedListProvider);
    final feeds = feedsAsync.asData?.value;

    useFab(
      ref,
      FloatingActionButton(
        heroTag: 'feeds_add_fab',
        onPressed: () => showAddFeedDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );

    return Stack(
      children: [
        if (feedsAsync.isLoading && feeds == null)
          const Center(child: CircularProgressIndicator())
        else if (feedsAsync.hasError && feeds == null)
          ErrorState(
            message: feedsAsync.error.toString(),
            onRetry: () => ref.invalidate(feedListProvider),
          )
        else if (feeds == null || feeds.isEmpty)
          EmptyState(
            icon: Icons.rss_feed_outlined,
            title: 'No feeds yet',
            subtitle: 'Add a feed URL to start discovering recipes from your favourite food blogs.',
            action: FilledButton.icon(
              onPressed: () => showAddFeedDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Feed'),
            ),
          )
        else
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(feedListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: feeds.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final feed = feeds[index];
                return Dismissible(
                  key: ValueKey(feed.id),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteBackground(),
                  confirmDismiss: (_) => showConfirmDialog(
                    context,
                    title: 'Remove Feed',
                    content: 'Remove "${feed.name}" and all its imported recipes from your feed?',
                    confirmLabel: 'Remove',
                    destructive: true,
                  ),
                  onDismissed: (_) {
                    _deleteFeed(ref, context, feed);
                  },
                  child: FeedCard(feed: feed),
                );
              },
            ),
          ),
      ],
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

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(
        Icons.delete_outlined,
        color: context.colors.onErrorContainer,
      ),
    );
  }
}
