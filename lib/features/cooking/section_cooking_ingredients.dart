import 'package:flutter/material.dart';

import '../../shared/components/recipes/ingredients.dart';
import '../../shared/components/recipes/scale_control.dart';
import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

class CookingIngredientsPage extends StatelessWidget {
  const CookingIngredientsPage({super.key, required this.recipe, required this.scale, required this.onScaleChanged});

  final Recipe recipe;
  final double scale;
  final ValueChanged<double> onScaleChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cookingPrepareToCook,
                  style: context.textTheme.headlineSmall,
                ),
                if (recipe.cookTime != null || recipe.totalTime != null) ...[
                  const SizedBox(height: UIConstants.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.cookingCookTimeLabel((recipe.cookTime ?? recipe.totalTime).toFormattedDuration(context)),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: UIConstants.paddingMedium),

          Ingredients(
            recipe.ingredients ?? [],
            equipment: recipe.equipment,
            scale: scale,
            headerTrailing: ScaleControl(
              recipe: recipe,
              initialScale: scale,
              onScaleChanged: onScaleChanged,
            ),
          ),
        ],
      ),
    );
  }
}
