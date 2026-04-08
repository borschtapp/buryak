import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/models/feed.dart';
import '../../shared/repositories/feed_repository.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'notifier_feed_list.dart';

/// Displays a single feed as a list tile with favicon, sync status badge, and resync action.
class FeedCard extends ConsumerWidget {
  final Feed feed;

  const FeedCard({
    super.key,
    required this.feed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _FeedImage(feed: feed),
      title: Text(
        feed.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text(
            Uri.tryParse(feed.url)?.host ?? feed.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          _SyncStatusBadge(feed: feed),
        ],
      ),
      trailing: Row(
        mainAxisSize: .min,
        children: [
          if (feed.totalRecipes != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(feed.totalRecipes!.pluralize('recipe')),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: const RoundedSuperellipseBorder(borderRadius: .all(.circular(8))),
                visualDensity: .compact,
              ),
            ),
          _ResyncButton(feedId: feed.id),
        ],
      ),
      isThreeLine: true,
    );
  }
}

class _FeedImage extends StatelessWidget {
  final Feed feed;

  const _FeedImage({required this.feed});

  @override
  Widget build(BuildContext context) {
    final imageUrl = feed.publisher?.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 24,
        height: 24,
        errorWidget: (_, _, _) => Icon(Icons.rss_feed, size: 24, color: context.colors.primary),
      );
    }

    return Icon(Icons.rss_feed, size: 24, color: context.colors.primary);
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final Feed feed;

  const _SyncStatusBadge({required this.feed});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _resolveStatus(context);
    return Row(
      mainAxisSize: .min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }

  (IconData, String, Color) _resolveStatus(BuildContext context) {
    if (feed.lastSyncSuccess == null) {
      return (Icons.sync_disabled, 'Never synced', context.colors.tertiary);
    }
    if (feed.lastSyncSuccess == true) {
      final when = feed.lastSyncAt?.timeAgo() ?? '';
      return (Icons.check_circle_outline, 'Synced $when', Colors.green);
    }
    return (Icons.error_outline, 'Sync failed', context.colors.error);
  }
}

class _ResyncButton extends HookConsumerWidget {
  final String feedId;

  const _ResyncButton({required this.feedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);

    Future<void> handleResync() async {
      loading.value = true;
      try {
        final result = await ref.read(feedRepositoryProvider).sync(feedId);
        ref.invalidate(feedListProvider);
        if (context.mounted) {
          final String message = switch (result) {
            null => 'Sync is taking longer than expected. It will continue in the background.',
            (0, _) => 'No recipes found.',
            (_, final imported) when imported > 0 => 'Imported ${imported.pluralize('new recipe')}.',
            _ => 'No new recipes found.',
          };
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        ref.handleException(e);
      } finally {
        loading.value = false;
      }
    }

    return IconButton(
      icon: loading.value
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.sync),
      tooltip: 'Resync feed',
      onPressed: loading.value ? null : handleResync,
    );
  }
}
