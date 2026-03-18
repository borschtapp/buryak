import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/ui_constants.dart';
import '../../shared/widgets/recipes/recipe_hero_image.dart';
import '../../shared/widgets/recipes/recipe_title_section.dart';
import '../../shared/widgets/recipes/recipe_meta_row.dart';
import '../../shared/widgets/recipes/view_ingredients.dart';
import '../../shared/widgets/recipes/view_instructions.dart';

class RecipeDesktopView extends StatelessWidget {
  const RecipeDesktopView({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RecipeHeroImage(
            recipe: recipe,
            height: UIConstants.recipeMaxImageHeightDesktop,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 32),
          RecipeTitleSection(recipe: recipe),
          const SizedBox(height: 12),
          RecipeMetaRow(recipe: recipe),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ContentSection(
                  title: 'Ingredients',
                  child: Ingredients(recipe.ingredients ?? [], equipment: recipe.equipment),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                child: _ContentSection(
                  title: 'Preparation',
                  child: Instructions(recipe.instructions ?? []),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineSmall),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
