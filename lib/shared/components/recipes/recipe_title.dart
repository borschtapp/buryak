import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/recipe.dart';
import '../../util/extensions.dart';
import 'author_line.dart';

/// Recipe name, author line, and published date.
///
/// [compact] = true for mobile (headlineSmall, author prefix + underline).
/// [compact] = false for desktop (headlineMedium, no prefix, no underline).
class RecipeTitle extends StatelessWidget {
  const RecipeTitle({
    super.key,
    required this.recipe,
    this.compact = false,
    this.padding = EdgeInsets.zero,
  });

  final Recipe recipe;
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final titleStyle = (compact ? context.textTheme.headlineSmall : context.textTheme.headlineMedium)?.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe.name, style: titleStyle),
          if (recipe.description != null) ...[
            const SizedBox(height: 4),
            Text(recipe.description!),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RecipeAuthorLine(
                recipe: recipe,
                showPrefix: compact,
                useUnderline: compact,
              ),
              if (recipe.published != null) ...[
                Text(
                  DateFormat.yMMMd(context.l10n.localeName).format(recipe.published!),
                  style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
