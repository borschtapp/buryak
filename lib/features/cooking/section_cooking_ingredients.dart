import 'package:flutter/material.dart';

import '../../shared/components/recipes/ingredients.dart';
import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';

class CookingIngredientsPage extends StatelessWidget {
  const CookingIngredientsPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prepare to cook',
                  style: context.textTheme.headlineSmall,
                ),
                if (recipe.cookTime != null || recipe.totalTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: context.colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cook: ${(recipe.cookTime ?? recipe.totalTime).toFormattedDuration()}',
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
          const SizedBox(height: 16),

          Ingredients(
            recipe.ingredients ?? [],
            equipment: recipe.equipment,
          ),
        ],
      ),
    );
  }
}
