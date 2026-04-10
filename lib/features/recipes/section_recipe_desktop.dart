import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../shared/components/recipes/hero_image.dart';
import '../../shared/components/recipes/ingredients.dart';
import '../../shared/components/recipes/instructions.dart';
import '../../shared/components/recipes/meta_row.dart';
import '../../shared/components/recipes/recipe_title.dart';
import '../../shared/components/recipes/scale_control.dart';
import '../../shared/models/recipe.dart';
import '../../shared/route_names.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'section_recipe_actions.dart';

class RecipeDesktopView extends HookWidget {
  const RecipeDesktopView({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final scale = useState(1.0);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: RecipeTitle(recipe: recipe)),
              if (recipe.hasCookableInstructions) ...[
                FilledButton.icon(
                  onPressed: () => context.pushNamed(
                    RouteNames.cooking,
                    pathParameters: {'rid': recipe.id},
                    extra: recipe,
                  ),
                  icon: const Icon(Icons.local_fire_department, size: 18),
                  label: const Text('Start Cooking'),
                ),
                const SizedBox(width: 8),
              ],
              RecipeActions(recipeId: recipe.id),
            ],
          ),
          const SizedBox(height: 12),
          RecipeMetaRow(recipe: recipe),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ContentSection(
                  title: 'Ingredients',
                  trailing: ScaleControl(
                    recipe: recipe,
                    initialScale: scale.value,
                    onScaleChanged: (s) => scale.value = s,
                  ),
                  child: Ingredients(
                    recipe.ingredients ?? [],
                    equipment: recipe.equipment,
                    scale: scale.value,
                    showHeader: false,
                  ),
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
  const _ContentSection({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: context.textTheme.headlineSmall),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
