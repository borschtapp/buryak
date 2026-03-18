import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/widgets/recipe_author_line.dart';
import '../../shared/widgets/recipe_placeholder.dart';
import '../../shared/ui_constants.dart';
import '../../shared/widgets/recipes/view_ingredients.dart';
import '../../shared/widgets/recipes/view_instructions.dart';
import '../../shared/widgets/recipes/view_nutrition.dart';

class RecipeMobileView extends StatefulWidget {
  final Recipe recipe;

  const RecipeMobileView({super.key, required this.recipe});

  @override
  State<RecipeMobileView> createState() => _RecipeMobileViewState();
}

class _RecipeMobileViewState extends State<RecipeMobileView> with TickerProviderStateMixin {
  late TabController _tabController;
  late bool _hasNutrition;

  @override
  void initState() {
    super.initState();
    _hasNutrition = _isNutritionAvailable(widget.recipe.nutrition);
    _tabController = TabController(length: _hasNutrition ? 3 : 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(RecipeMobileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasNutrition = _isNutritionAvailable(widget.recipe.nutrition);
    if (hasNutrition != _hasNutrition) {
      final previousIndex = _tabController.index;
      _tabController.dispose();
      _hasNutrition = hasNutrition;
      _tabController = TabController(
        length: _hasNutrition ? 3 : 2,
        vsync: this,
        initialIndex: previousIndex.clamp(0, _hasNutrition ? 2 : 1),
      );
      _tabController.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs(_hasNutrition);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RecipeHero(recipe: widget.recipe),
              _RecipeTitle(recipe: widget.recipe),
            ],
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: context.colors.primary,
              labelColor: context.colors.primary,
              unselectedLabelColor: context.colors.onSurfaceVariant,
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              tabs: tabs,
            ),
            Theme.of(context).colorScheme.surface,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildActiveView(),
        ),
      ],
    );
  }

  Widget _buildActiveView() {
    switch (_tabController.index) {
      case 0:
        return Ingredients(widget.recipe.ingredients ?? [], equipment: widget.recipe.equipment);
      case 1:
        return Instructions(widget.recipe.instructions ?? []);
      case 2:
        return Nutrition(widget.recipe.nutrition);
      default:
        return const SizedBox.shrink();
    }
  }

  List<Tab> _buildTabs(bool hasNutrition) {
    final tabs = <Tab>[
      Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${widget.recipe.ingredients?.length ?? 0}', style: const TextStyle(fontSize: 16)),
            const Text('Ingredients', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
      Tab(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.recipe.totalTime.toFormattedDuration(), style: const TextStyle(fontSize: 16)),
            const Text('Instructions', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    ];

    if (hasNutrition) {
      tabs.add(
        const Tab(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 16),
              Text('Facts', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );
    }

    return tabs;
  }

  bool _isNutritionAvailable(dynamic nutrition) {
    if (nutrition == null) return false;

    return nutrition.calories != null ||
        nutrition.protein != null ||
        nutrition.fat != null ||
        nutrition.carbs != null ||
        nutrition.fatSaturated != null ||
        nutrition.carbsFiber != null ||
        nutrition.carbsSugar != null ||
        nutrition.sodium != null;
  }
}

class _RecipeHero extends StatelessWidget {
  final Recipe recipe;

  const _RecipeHero({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final image = recipe.primaryImageUrl;

    return Stack(
      children: [
        if (image != null)
          Hero(
            tag: 'recipe_detail_${recipe.id}',
            child: Semantics(
              label: 'Photo of ${recipe.name}',
              excludeSemantics: true,
              child: CachedNetworkImage(
                imageUrl: image,
                height: min(context.mediaQuery.size.height * 0.4, UIConstants.recipeMaxImageHeight),
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const RecipePlaceholder(),
              ),
            ),
          )
        else
          Hero(
            tag: 'recipe_detail_${recipe.id}',
            child: const RecipePlaceholder(),
          ),
        if (recipe.rating?.value != null && recipe.rating!.value! > 0)
          Positioned(
            bottom: 16,
            left: 16,
            child: _RatingBadge(rating: recipe.rating!.value!),
          ),
      ],
    );
  }
}


class _RatingBadge extends StatelessWidget {
  final double? rating;

  const _RatingBadge({this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: context.colors.primary, size: 18),
          const SizedBox(width: 4),
          Text(
            rating?.toStringAsFixed(1) ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeTitle extends StatelessWidget {
  final Recipe recipe;

  const _RecipeTitle({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.name,
            style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RecipeAuthorLine(recipe: recipe),
          const SizedBox(height: 4),
          if (recipe.published != null)
            Text(
              'Published: ${DateFormat.yMMMd().format(recipe.published!)}',
              style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height + 10;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 10;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: Column(children: [_tabBar, const Divider(height: 1, thickness: 1)]),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor || oldDelegate._tabBar != _tabBar;
}
