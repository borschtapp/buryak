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
    final name = recipe.author?.name ?? recipe.publisher?.name;
    final url = recipe.author?.url ?? recipe.publisher?.url;

    if (name == null) return const SizedBox.shrink();

    final textStyle = context.isMobile ? context.textTheme.bodySmall : context.textTheme.bodyMedium;

    if (url != null && url.trim().isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPrefix) Text('Published by ', style: textStyle?.copyWith(color: context.colors.onSurfaceVariant)),
          InkWell(
            onTap: () async {
              try {
                final success = await launchUrlString(url);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open source link')),
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
          ),
        ],
      );
    }

    return Text(
      name,
      style: textStyle,
    );
  }
}
