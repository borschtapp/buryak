import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../shared/components/recipes/hero_image.dart';
import '../../shared/components/recipes/ingredients.dart';
import '../../shared/components/recipes/instructions.dart';
import '../../shared/components/recipes/meta_row.dart';
import '../../shared/components/recipes/nutrition.dart';
import '../../shared/components/recipes/recipe_title.dart';
import '../../shared/components/recipes/scale_control.dart';
import '../../shared/components/recipes/sticky_tab_bar_delegate.dart';
import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'section_recipe_actions.dart';

class RecipeMobileView extends HookWidget {
  const RecipeMobileView({super.key, required this.recipe, this.backFallback});

  final Recipe recipe;
  final String? backFallback;

  @override
  Widget build(BuildContext context) {
    final hasNutrition = recipe.nutrition?.hasData ?? false;
    final tabController = useTabController(
      initialLength: hasNutrition ? 3 : 2,
      keys: [hasNutrition],
    );
    final scale = useState(1.0);

    final heroHeight = min(MediaQuery.heightOf(context) * 0.4, UIConstants.recipeMaxImageHeight);
    final scrollController = useScrollController();

    final ratingBadge = recipe.rating?.value != null && recipe.rating!.value! > 0 ? _RatingBadge(rating: recipe.rating!.value!) : null;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        _RecipeSliverAppBar(
          recipe: recipe,
          scrollController: scrollController,
          heroHeight: heroHeight,
          ratingBadge: ratingBadge,
          backFallback: backFallback,
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
            builder: (_, _) {
              return switch (tabController.index) {
                0 => Ingredients(
                  recipe.ingredients ?? [],
                  equipment: recipe.equipment,
                  scale: scale.value,
                  headerTrailing: ScaleControl(
                    recipe: recipe,
                    initialScale: scale.value,
                    onScaleChanged: (s) => scale.value = s,
                  ),
                ),
                1 => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Instructions(recipe.instructions ?? []),
                ),
                _ => Nutrition(recipe.nutrition),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _RecipeSliverAppBar extends HookWidget {
  const _RecipeSliverAppBar({
    required this.recipe,
    required this.scrollController,
    required this.heroHeight,
    this.ratingBadge,
    this.backFallback,
  });

  final Recipe recipe;
  final ScrollController scrollController;
  final double heroHeight;
  final Widget? ratingBadge;
  final String? backFallback;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final collapseThreshold = heroHeight - kToolbarHeight - topPadding;

    final isCollapsed = useState(
      scrollController.hasClients && scrollController.offset >= collapseThreshold,
    );

    useEffect(() {
      void listener() {
        final collapsed = scrollController.hasClients && scrollController.offset >= collapseThreshold;
        if (isCollapsed.value != collapsed) isCollapsed.value = collapsed;
      }

      scrollController.addListener(listener);
      return () => scrollController.removeListener(listener);
    }, [scrollController, collapseThreshold]);

    return SliverAppBar(
      pinned: true,
      expandedHeight: heroHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.colors.surface,
      foregroundColor: isCollapsed.value ? context.colors.onSurface : Colors.white,
      leading: BackButton(
        onPressed: backFallback != null ? () => context.popOrGoNamed(backFallback!) : null,
      ),
      actions: [
        RecipeActions(recipeId: recipe.id),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            RecipeHeroImage(recipe: recipe, height: heroHeight, overlay: ratingBadge),
            // Gradient to keep toolbar icons legible over any hero image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topPadding + kToolbarHeight + 24,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
