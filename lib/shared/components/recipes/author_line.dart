import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/recipe.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';

class RecipeAuthorLine extends ConsumerWidget {
  final Recipe recipe;
  final bool showPrefix;
  final bool useUnderline;

  const RecipeAuthorLine({
    super.key,
    required this.recipe,
    this.showPrefix = true,
    this.useUnderline = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorName = recipe.author?.name;
    final authorUrl = recipe.author?.url?.trim();
    final publisherName = recipe.publisher?.name;
    final publisherUrl = recipe.publisher?.url?.trim();

    if (authorName == null && publisherName == null) return const SizedBox.shrink();

    final textStyle = context.isMobile ? context.textTheme.bodySmall : context.textTheme.bodyMedium;

    Widget buildLink(String name, String? url) {
      if (url != null && url.isNotEmpty) {
        return InkWell(
          onTap: () async {
            try {
              final success = await launchUrlString(url);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.authorSourceLinkError)),
                );
              }
            } catch (e) {
              ref.handleException(e);
            }
          },
          child: Text(
            name,
            style: textStyle?.copyWith(
              color: context.colors.primary,
              decoration: useUnderline ? TextDecoration.underline : null,
            ),
          ),
        );
      }
      return Text(name, style: textStyle);
    }

    if (authorName != null && publisherName != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildLink(publisherName, publisherUrl),
          Text(' · ', style: textStyle?.copyWith(color: context.colors.onSurfaceVariant)),
          buildLink(authorName, authorUrl),
        ],
      );
    }

    final name = authorName ?? publisherName!;
    final url = (authorUrl?.isNotEmpty ?? false) ? authorUrl : publisherUrl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPrefix) Text(context.l10n.authorPublishedBy, style: textStyle?.copyWith(color: context.colors.onSurfaceVariant)),
        buildLink(name, url),
      ],
    );
  }
}
