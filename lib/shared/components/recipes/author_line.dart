import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../extensions.dart';
import '../../models/recipe.dart';

class RecipeAuthorLine extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
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
