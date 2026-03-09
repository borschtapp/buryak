import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import 'view_recipe_tile.dart';

class RecipesGridView extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isFavorite;
  const RecipesGridView(
    this.recipes, {
    super.key,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(5),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.isMobile
                ? max(1, constraints.maxWidth ~/ 300)
                : max(1, constraints.maxWidth ~/ 350),
            childAspectRatio: constraints.isMobile ? 1.2 : 1.1,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return InkWell(
              borderRadius: context.shapeSmall,
              child: RecipeTile(recipe.id, recipe, isFavorite: isFavorite),
              onTap: () => context.goNamed('recipe', pathParameters: {'rid': recipe.id}),
            );
          },
        );
      },
    );
  }
}
