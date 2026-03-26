import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../shared/components/recipes/hero_image.dart';
import '../../shared/components/recipes/ingredients.dart';
import '../../shared/components/recipes/instructions.dart';
import '../../shared/components/recipes/meta_row.dart';
import '../../shared/components/recipes/nutrition.dart';
import '../../shared/components/recipes/recipe_title.dart';
import '../../shared/components/recipes/sticky_tab_bar_delegate.dart';
import '../../shared/extensions.dart';
import '../../shared/models/recipe.dart';
import '../../shared/ui_constants.dart';

class RecipeMobileView extends HookWidget {
  const RecipeMobileView({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final hasNutrition = recipe.nutrition?.hasData ?? false;
    final tabController = useTabController(
      initialLength: hasNutrition ? 3 : 2,
      keys: [hasNutrition],
    );

    final heroHeight = min(MediaQuery.heightOf(context) * 0.4, UIConstants.recipeMaxImageHeight);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RecipeHeroImage(
                recipe: recipe,
                height: heroHeight,
                overlay: recipe.rating?.value != null && recipe.rating!.value! > 0 ? _RatingBadge(rating: recipe.rating!.value!) : null,
              ),
              RecipeTitle(
                recipe: recipe,
                compact: true,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              ),
              RecipeMetaRow(
                recipe: recipe,
                showTime: false,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              ),
            ],
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyTabBarDelegate(
            backgroundColor: context.colors.surface,
            tabBar: TabBar(
              controller: tabController,
              isScrollable: false,
              indicatorColor: context.colors.primary,
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.onSurfaceVariant,
              labelStyle: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${recipe.ingredients?.length ?? 0}', style: context.textTheme.titleMedium),
                      Text('Ingredients', style: context.textTheme.labelSmall),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(recipe.totalTime.toFormattedDuration(), style: context.textTheme.titleMedium),
                      Text('Instructions', style: context.textTheme.labelSmall),
                    ],
                  ),
                ),
                if (hasNutrition)
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant_menu_outlined, size: 18),
                        Text('Facts', style: context.textTheme.labelSmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListenableBuilder(
            listenable: tabController,
            builder: (_, _) => Column(
              children: [
                Offstage(
                  offstage: tabController.index != 0,
                  child: Ingredients(recipe.ingredients ?? [], equipment: recipe.equipment),
                ),
                Offstage(
                  offstage: tabController.index != 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Instructions(recipe.instructions ?? []),
                  ),
                ),
                if (hasNutrition)
                  Offstage(
                    offstage: tabController.index != 2,
                    child: Nutrition(recipe.nutrition),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.59),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: context.colors.primary, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
