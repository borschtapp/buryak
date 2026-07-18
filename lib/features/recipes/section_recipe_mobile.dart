import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/icon_label.dart';
import '../../shared/components/recipes/hero_image.dart';
import '../../shared/components/recipes/ingredients.dart';
import '../../shared/components/recipes/instructions.dart';
import '../../shared/components/recipes/meta_row.dart';
import '../../shared/components/recipes/nutrition.dart';
import '../../shared/components/recipes/recipe_cost.dart';
import '../../shared/components/recipes/recipe_title.dart';
import '../../shared/components/recipes/scale_control.dart';
import '../../shared/components/recipes/sticky_tab_bar_delegate.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_cost_estimate.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/providers/household.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'dialog_edit_food.dart';
import 'dialog_edit_ingredient.dart';
import 'dialog_food_price.dart';
import 'section_recipe_actions.dart';

enum _RecipeTab { ingredients, instructions, cost, nutrition }

class RecipeMobileSection extends HookConsumerWidget {
  const RecipeMobileSection({super.key, required this.recipe, this.backFallback});

  final Recipe recipe;
  final String? backFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNutrition = recipe.nutrition?.hasData ?? false;
    final hasFoodIngredients = recipe.hasFoodIngredients;

    final tabs = [
      _RecipeTab.ingredients,
      _RecipeTab.instructions,
      if (hasFoodIngredients) _RecipeTab.cost,
      if (hasNutrition) _RecipeTab.nutrition,
    ];

    final tabController = useTabController(
      initialLength: tabs.length,
      keys: [hasFoodIngredients, hasNutrition],
    );
    final scale = useState(1.0);

    final heroHeight = min(MediaQuery.heightOf(context) * 0.4, UIConstants.recipeMaxImageHeight);
    final scrollController = useScrollController();

    final ratingBadge = recipe.rating?.value != null && recipe.rating!.value! > 0 ? _RatingBadge(rating: recipe.rating!.value!) : null;

    final estimateAsync = hasFoodIngredients ? ref.watch(recipeCostEstimateProvider(recipe.id)) : null;
    final currency = hasFoodIngredients ? ref.watch(householdProvider).value?.currency : null;

    void openEditIngredient(RecipeIngredient ingredient) {
      EditIngredientBottomSheet.show(
        context,
        recipeId: recipe.id,
        ingredient: ingredient,
      );
    }

    void openEditFood(RecipeIngredient ingredient) {
      final food = ingredient.food;
      if (food == null) return;
      EditFoodBottomSheet.show(context, food: food, recipeId: recipe.id);
    }

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
                padding: const EdgeInsets.fromLTRB(
                  UIConstants.paddingContent,
                  UIConstants.paddingContent,
                  UIConstants.paddingContent,
                  4,
                ),
              ),
              RecipeMetaRow(
                recipe: recipe,
                showTime: false,
                padding: const EdgeInsets.fromLTRB(
                  UIConstants.paddingContent,
                  0,
                  UIConstants.paddingContent,
                  UIConstants.paddingMedium,
                ),
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
                for (final tab in tabs)
                  switch (tab) {
                    _RecipeTab.ingredients => Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${recipe.ingredients?.length ?? 0}', style: context.textTheme.titleMedium),
                          Text(context.l10n.recipesIngredients, style: context.textTheme.labelSmall),
                        ],
                      ),
                    ),
                    _RecipeTab.instructions => Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(recipe.totalTime?.asDuration?.localized(context.l10n) ?? '-', style: context.textTheme.titleMedium),
                          Text(context.l10n.recipesInstructions, style: context.textTheme.labelSmall),
                        ],
                      ),
                    ),
                    _RecipeTab.cost => Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _CostTabValue(estimate: estimateAsync?.value, currency: currency),
                          Text(context.l10n.recipeCostFacts, style: context.textTheme.labelSmall),
                        ],
                      ),
                    ),
                    _RecipeTab.nutrition => Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_menu_outlined, size: 18),
                          Text(context.l10n.recipesNutritionFacts, style: context.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  },
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListenableBuilder(
            listenable: tabController,
            builder: (_, _) {
              return switch (tabs[tabController.index]) {
                _RecipeTab.ingredients => Ingredients(
                  recipe.ingredients ?? [],
                  equipment: recipe.equipment,
                  scale: scale.value,
                  onIngredientTap: openEditIngredient,
                  onIngredientLongPress: openEditFood,
                  headerTrailing: ScaleControl(
                    recipe: recipe,
                    initialScale: scale.value,
                    onScaleChanged: (s) => scale.value = s,
                  ),
                ),
                _RecipeTab.instructions => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Instructions(recipe.instructions ?? []),
                ),
                _RecipeTab.cost => RecipeCost(
                  recipeId: recipe.id,
                  ingredients: recipe.ingredients ?? [],
                  onAddPrice: (ingredient) => FoodPriceBottomSheet.show(
                    context,
                    food: ingredient.food!,
                    recipeId: recipe.id,
                    ingredient: ingredient,
                  ),
                  onIngredientTap: openEditIngredient,
                  onIngredientLongPress: openEditFood,
                ),
                _RecipeTab.nutrition => Nutrition(recipe.nutrition),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _CostTabValue extends StatelessWidget {
  const _CostTabValue({
    required this.estimate,
    required this.currency,
  });

  final RecipeCostEstimate? estimate;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    if (estimate == null) {
      return const Icon(Icons.attach_money_outlined, size: 18);
    }
    if (!estimate!.isComplete) {
      return Text(
        context.l10n.recipeCostTabMissing(estimate!.missingCount),
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.error,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (estimate!.perServing != null) {
      final formatted = context.currencyFormatter(currency).format(estimate!.perServing);
      return Text(
        formatted,
        style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const Icon(Icons.attach_money_outlined, size: 18);
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
        const SizedBox(width: UIConstants.paddingSmall),
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
      child: IconLabel(
        icon: Icons.star,
        label: rating.toStringAsFixed(1),
        color: context.colors.primary,
        iconSize: 18,
        textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
