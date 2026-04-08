import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/repositories/feed_repository.dart';
import 'notifier_feed_list.dart';
import 'screen_feed.dart';

void showAddFeedDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => TextInputDialog(
      title: 'Add New Feed',
      hintText: 'Feed URL (RSS/Atom)',
      helperText: 'Enter the URL of a recipe blog or podcast feed.',
      submitLabel: 'Add',
      validator: (value) => value.isEmpty ? 'URL cannot be empty' : null,
      onSubmit: (url, ctx) async {
        await ref.read(feedRepositoryProvider).subscribe(url);

        // Invalidate both the stream (recipes) and the list (management)
        ref.invalidate(feedListProvider);
        ref.invalidate(feedStreamProvider);

        if (ctx.mounted) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Feed added! Recipes will appear shortly.')),
          );
        }
      },
    ),
  );
}
