import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/recipe.dart';
import '../../extensions.dart';
import '../recipe_author_line.dart';

/// Recipe name, author line, and published date.
///
/// [compact] = true for mobile (headlineSmall, author prefix + underline).
/// [compact] = false for desktop (headlineMedium, no prefix, no underline).
class RecipeTitleSection extends StatelessWidget {
  const RecipeTitleSection({
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
    final titleStyle = (compact ? context.textTheme.headlineSmall : context.textTheme.headlineMedium)
        ?.copyWith(fontWeight: FontWeight.bold);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe.name, style: titleStyle),
          const SizedBox(height: 8),
          RecipeAuthorLine(
            recipe: recipe,
            showPrefix: compact,
            useUnderline: compact,
          ),
          if (recipe.published != null) ...[
            const SizedBox(height: 4),
            Text(
              'Published: ${DateFormat.yMMMd().format(recipe.published!)}',
              style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
