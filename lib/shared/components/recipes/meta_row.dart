import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../util/extensions.dart';

/// Metadata row + taxonomy chips for a recipe.
///
/// On mobile, pass [showTime] = false since cook time already appears in the
/// Instructions tab label. On desktop (no tabs) it defaults to true.
class RecipeMetaRow extends StatelessWidget {
  const RecipeMetaRow({
    super.key,
    required this.recipe,
    this.padding = EdgeInsets.zero,
    this.showTime = true,
  });

  final Recipe recipe;
  final EdgeInsetsGeometry padding;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final chips = _taxonomyChips(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              if (showTime) _MetaItem(icon: Icons.timer_outlined, label: recipe.totalTime.toFormattedDuration()),
              if (recipe.yield != null && recipe.yield! > 0) _MetaItem(icon: Icons.restaurant_outlined, label: '${recipe.yield} servings'),
              if (recipe.difficulty != null && recipe.difficulty!.isNotEmpty)
                _MetaItem(icon: Icons.signal_cellular_alt_outlined, label: recipe.difficulty!),
              if (recipe.method != null && recipe.method!.isNotEmpty)
                _MetaItem(icon: Icons.local_fire_department_outlined, label: recipe.method!),
              if (recipe.rating?.value != null && recipe.rating!.value! > 0)
                _MetaItem(
                  icon: Icons.star_outline_rounded,
                  label: recipe.rating!.value!.toStringAsFixed(1),
                  iconColor: Colors.amber,
                ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: chips),
          ],
        ],
      ),
    );
  }

  List<Widget> _taxonomyChips(BuildContext context) {
    final taxonomies = recipe.taxonomies;
    if (taxonomies == null || taxonomies.isEmpty) return [];

    // Show cuisine, meal type, diet, and occasion — skip entries without labels
    const relevantTypes = {'cuisine', 'meal_type', 'diet', 'occasion', 'category'};
    final filtered = taxonomies
        .where((t) => t.label != null && t.label!.isNotEmpty)
        .where((t) => t.type == null || relevantTypes.contains(t.type))
        .take(5)
        .toList();

    return filtered
        .map(
          (t) => Chip(
            label: Text(t.label!),
            labelStyle: context.textTheme.labelSmall,
            padding: EdgeInsets.zero,
            side: BorderSide(color: context.colors.outlineVariant),
            backgroundColor: context.colors.surfaceContainerHighest,
            visualDensity: VisualDensity.compact,
          ),
        )
        .toList();
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label, this.iconColor});

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor ?? context.colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
      ],
    );
  }
}
