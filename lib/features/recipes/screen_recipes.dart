import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/repositories/recipe_repository.dart';
import 'view_recipes_grid.dart';
import '../../shared/views/async_loader.dart';
import '../../shared/providers/recipe_notifier.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
    RecipeRefreshNotifier().addListener(_refresh);
  }

  @override
  void dispose() {
    RecipeRefreshNotifier().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _recipesFuture = RecipeRepository.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<Recipe>>(
      future: _recipesFuture,
      builder: (context, results) {
        return RecipesGridView(results, isFavorite: true);
      },
    );
  }
}
