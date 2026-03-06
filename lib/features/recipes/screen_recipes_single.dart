import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../shared/repositories/recipe_repository.dart';
import '../../shared/extensions.dart';
import '../../shared/models/recipe.dart';
import '../../shared/views/async_loader.dart';
import 'view_ingredients.dart';
import 'view_instructions.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late Future<Recipe> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = RecipeRepository.findOne(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<Recipe>(
      future: _recipeFuture,
      builder: (context, recipe) {
        if (context.isMobile) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: buildMobile(context, recipe),
              bottomNavigationBar: buildBottomBar(context),
            ),
          );
        }
        return SingleChildScrollView(child: buildDesktop(context, recipe));
      },
    );
  }

  Widget buildMobile(BuildContext context, Recipe recipe) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  recipe.images != null && recipe.images!.isNotEmpty
                      ? Image.network(
                          recipe.images!.last.url ?? '',
                          height: min(context.mediaQuery.size.height * 0.4, 400),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/recipe_placeholder.png',
                            height: min(context.mediaQuery.size.height * 0.4, 400),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/recipe_placeholder.png',
                          height: min(context.mediaQuery.size.height * 0.4, 400),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
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
                            recipe.rating?.value?.toStringAsFixed(2) ?? '0.00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (recipe.author?.name != null || recipe.publisher?.name != null)
                      Builder(
                        builder: (context) {
                          final name = (recipe.author?.name ?? recipe.publisher?.name)!;
                          final url = recipe.author?.url ?? recipe.publisher?.url;
                          return Row(
                            children: [
                              Text('Published by ', style: context.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                              if (url != null && url.isNotEmpty)
                                InkWell(
                                  onTap: () => launchUrlString(url),
                                  child: Text(
                                    name,
                                    style: context.textTheme.bodySmall?.copyWith(
                                      color: context.colors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              else
                                Text(name, style: context.textTheme.bodySmall),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
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
              unselectedLabelColor: Colors.grey,
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
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Ingredients(recipe.ingredients ?? []),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Instructions(recipe.instructions ?? []),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDesktop(BuildContext context, Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: recipe.images != null && recipe.images!.isNotEmpty
                ? Image.network(
                    recipe.images!.last.url ?? '',
                    height: 500,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/recipe_placeholder.png',
                      height: 500,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/recipe_placeholder.png',
                    height: 500,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 32),
          recipeHeader(recipe),
          const SizedBox(height: 8),
          if (recipe.author?.name != null || recipe.publisher?.name != null)
            Text(recipe.author?.name ?? recipe.publisher?.name ?? '', style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          recipeDetails(recipe),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ingredients', style: context.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Ingredients(recipe.ingredients ?? []),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preparation', style: context.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Instructions(recipe.instructions ?? []),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.secondary.withAlpha(50))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: context.colors.primary),
              ),
              child: const Text('Add to'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFB7B7), // Pinkish color from screenshot
                foregroundColor: Colors.black,
              ),
              child: const Text('Go to cook'),
            ),
          ),
        ],
      ),
    );
  }

  Widget recipeHeader(Recipe recipe) {
    return Text(
      recipe.name,
      style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget recipeDetails(Recipe recipe) {
    return Row(
      children: [
        const Icon(Icons.timer, size: 20),
        const SizedBox(width: 4),
        Text(recipe.cookTime.toFormattedDuration()),
        const SizedBox(width: 24),
        const Icon(Icons.restaurant, size: 20),
        const SizedBox(width: 4),
        Text('${recipe.yield ?? 0} Servings'),
        const SizedBox(width: 24),
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(recipe.rating?.value?.toStringAsFixed(2) ?? '0.00'),
      ],
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
