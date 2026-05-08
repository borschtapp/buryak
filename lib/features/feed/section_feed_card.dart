import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/icon_label.dart';
import '../../shared/components/loading_button.dart';
import '../../shared/components/standard_picture.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            feed.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          _SyncStatusBadge(feed: feed),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feed.totalRecipes != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(feed.totalRecipes!.pluralize('recipe')),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                visualDensity: VisualDensity.compact,
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
    return StandardPicture(
      imageUrl: feed.publisher?.imageUrl,
      fallbackIcon: Icons.rss_feed,
      size: 40,
      shape: PictureShape.rounded,
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final Feed feed;

  const _SyncStatusBadge({required this.feed});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = _resolveStatus(context);
    return IconLabel(
      icon: icon,
      label: label,
      color: color,
      textStyle: context.textTheme.labelSmall,
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
        if (context.mounted) {
          loading.value = false;
        }
      }
    }

    return LoadingButton(
      isLoading: loading.value,
      onPressed: handleResync,
      type: LoadingButtonType.text,
      spinnerSize: 18,
      child: const Icon(Icons.sync),
    );
  }
}
