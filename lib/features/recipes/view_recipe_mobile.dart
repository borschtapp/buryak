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

class RecipeMobileView extends StatelessWidget {
  final Recipe recipe;

  const RecipeMobileView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RecipeHero(recipe: recipe),
                _RecipeTitle(recipe: recipe),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
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
                        Text('${recipe.ingredients?.length ?? 0}', style: const TextStyle(fontSize: 16)),
                        const Text('Ingredients', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(recipe.totalTime.toFormattedDuration(), style: const TextStyle(fontSize: 16)),
                        const Text('Instructions', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
              context.colors.surface,
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              children: [
                Ingredients(recipe.ingredients ?? [], equipment: recipe.equipment),
                Instructions(recipe.instructions ?? []),
              ],
            ),
          ),
        ],
      ),
    );
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => oldDelegate.backgroundColor != backgroundColor;
}
