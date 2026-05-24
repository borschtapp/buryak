import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/feed/notifier_feed.dart';
import '../../../features/feed/notifier_feed_list.dart';
import '../../providers/saved.dart';
import '../../repositories/import_repository.dart';
import '../../route_names.dart';
import '../../util/extensions.dart';
import '../../util/validator.dart';
import '../dialog_text_input.dart';

void showImportDialog(BuildContext context, WidgetRef ref, {bool isFeedOnly = false}) {
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => TextInputDialog(
      title: isFeedOnly ? l10n.importAddFeed : l10n.importFromUrl,
      hintText: isFeedOnly ? l10n.importFeedUrl : l10n.importRecipeFeedUrl,
      helperText: isFeedOnly ? l10n.importHelperFeed : l10n.importHelperRecipe,
      submitLabel: isFeedOnly ? l10n.importAddSubmit : l10n.importSubmit,
      validator: (value) => Validator.validateUrl(Validator.extractUrl(value), l10n),
      onSubmit: (url, ctx) async {
        try {
          final cleanUrl = Validator.extractUrl(url);
          final result = await ref
              .read(importRepositoryProvider)
              .import(
                cleanUrl,
                type: isFeedOnly ? 'feed' : 'auto',
              );

          // Invalidate relevant providers to refresh the UI
          ref.invalidate(feedListProvider);
          ref.invalidate(feedStreamProvider);
          ref.invalidate(savedRecipesProvider);

          if (ctx.mounted) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(result.recipe != null ? l10n.importSuccessRecipe : l10n.importSuccessFeed),
                backgroundColor: Colors.green,
              ),
            );

            if (result.recipe != null) {
              GoRouter.of(ctx).pushNamed(RouteNames.recipe, pathParameters: {'rid': result.recipe!.id});
            } else if (!isFeedOnly) {
              // If we're not already on the feeds management or home feed, navigate there
              GoRouter.of(ctx).goNamed(RouteNames.feed);
            }
          }
        } catch (e) {
          // Don't pop on error to allow the user to correct the URL
          rethrow;
        }
      },
    ),
  );
}
