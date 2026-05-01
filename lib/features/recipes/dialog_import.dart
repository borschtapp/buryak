import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_text_input.dart';
import '../../shared/providers/saved.dart';
import '../../shared/repositories/import_repository.dart';
import '../../shared/route_names.dart';
import '../../shared/util/validator.dart';
import '../feed/notifier_feed_list.dart';
import '../feed/screen_feed.dart';

void showImportDialog(BuildContext context, WidgetRef ref, {bool isFeedOnly = false}) {
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => TextInputDialog(
      title: isFeedOnly ? 'Add Feed' : 'Import from URL',
      hintText: isFeedOnly ? 'Feed URL' : 'Recipe or Feed URL',
      helperText: isFeedOnly ? 'Paste a link to a blog feed to subscribe to it.' : 'Paste a link to a recipe or a blog feed to import it.',
      submitLabel: isFeedOnly ? 'Add' : 'Import',
      validator: (value) => Validator.validateUrl(Validator.extractUrl(value)),
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
                content: Text(result.recipe != null ? 'Recipe imported.' : 'Feed added! Recipes will appear shortly.'),
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
