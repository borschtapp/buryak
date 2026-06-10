import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../util/extensions.dart';
import '../icon_label.dart';

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
              if (showTime)
                IconLabel(
                  icon: Icons.timer_outlined,
                  label: recipe.totalTime.asDuration?.localized(context.l10n) ?? '-',
                  color: context.colors.onSurfaceVariant,
                ),
              if (recipe.yield != null && recipe.yield! > 0)
                IconLabel(
                  icon: Icons.restaurant_outlined,
                  label: context.l10n.recipeYieldServings(recipe.yield!),
                  color: context.colors.onSurfaceVariant,
                ),
              if (recipe.difficulty != null && recipe.difficulty!.isNotEmpty)
                IconLabel(icon: Icons.signal_cellular_alt_outlined, label: recipe.difficulty!, color: context.colors.onSurfaceVariant),
              if (recipe.method != null && recipe.method!.isNotEmpty)
                IconLabel(icon: Icons.local_fire_department_outlined, label: recipe.method!, color: context.colors.onSurfaceVariant),
              if (recipe.rating?.value != null && recipe.rating!.value! > 0)
                IconLabel(
                  icon: Icons.star_outline_rounded,
                  label: recipe.rating!.value!.toStringAsFixed(1),
                  color: Colors.amber,
                  iconSize: 16,
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
