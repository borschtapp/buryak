import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/repositories/recipe_repository.dart';
import '../../shared/views/async_loader.dart';
import '../recipes/view_recipes_grid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final Future<List<Recipe>> _recipesFuture = RecipeRepository.explore();

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<Recipe>>(
      future: _recipesFuture,
      builder: (context, results) {
        return RecipesGridView(results, isFavorite: false);
      },
    );
  }
}
