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
  List<Recipe>? _cachedRecipes;

  @override
  void initState() {
    super.initState();
    _refreshAll();
    RecipeRefreshNotifier().addListener(_onRecipeChanged);
  }

  @override
  void dispose() {
    RecipeRefreshNotifier().removeListener(_onRecipeChanged);
    super.dispose();
  }

  void _refreshAll() {
    setState(() {
      _recipesFuture = RecipeRepository.findAll(preload: 'images,collections,saved,publisher').then((recipes) {
        _cachedRecipes = recipes;
        return recipes;
      });
    });
  }

  void _onRecipeChanged() async {
    final notifier = RecipeRefreshNotifier();
    final action = notifier.lastAction;
    final recipeId = notifier.lastRecipeId;
    final data = notifier.lastData;

    if (_cachedRecipes == null) {
      _refreshAll();
      return;
    }

    bool updated = false;

    if (action == 'delete' && recipeId != null) {
      _cachedRecipes!.removeWhere((r) => r.id == recipeId);
      updated = true;
    } else if (action == 'create' && data is Recipe) {
      if (!_cachedRecipes!.any((r) => r.id == data.id)) {
        _cachedRecipes!.insert(0, data);
      }
      updated = true;
    } else if (action == 'update' && data is Recipe) {
      final index = _cachedRecipes!.indexWhere((r) => r.id == data.id);
      if (index != -1) {
        _cachedRecipes![index] = data;
      } else {
        _cachedRecipes!.insert(0, data);
      }
      updated = true;
    } else if (action == 'save' && recipeId != null) {
      try {
        final r = await RecipeRepository.findOne(recipeId);
        if (mounted) {
          final exists = _cachedRecipes!.any((item) => item.id == recipeId);
          if (!exists) {
            _cachedRecipes!.insert(0, r);
            setState(() {
              _recipesFuture = Future.value(_cachedRecipes);
            });
          }
        }
      } catch (_) {}
      return;
    } else if (action == 'unsave' && recipeId != null) {
      _cachedRecipes!.removeWhere((r) => r.id == recipeId);
      updated = true;
    } else {
      _refreshAll();
      return;
    }

    if (updated && mounted) {
      setState(() {
        _recipesFuture = Future.value(_cachedRecipes);
      });
    }
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
