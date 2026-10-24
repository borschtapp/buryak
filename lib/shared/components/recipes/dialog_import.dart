import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/feed/notifier_feed_list.dart';
import '../../route_names.dart';
import '../../util/extensions.dart';
import '../../util/validator.dart';
import '../dialog_text_input.dart';

void showImportDialog(BuildContext context, {bool isFeedOnly = false}) {
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
      mutation: importMutation,
      onSubmit: (tsx, url) => tsx.get(feedListProvider.notifier).importUrl(Validator.extractUrl(url), feedOnly: isFeedOnly),
      onSuccess: (result) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.recipe != null ? l10n.importSuccessRecipe : l10n.importSuccessFeed),
            backgroundColor: Colors.green,
          ),
        );

        if (result.recipe != null) {
          context.pushNamed(RouteNames.recipe, pathParameters: {'rid': result.recipe!.id});
        } else if (!isFeedOnly) {
          // If we're not already on the feeds management or home feed, navigate there
          context.goNamed(RouteNames.feed);
        }
      },
    ),
  );
}
