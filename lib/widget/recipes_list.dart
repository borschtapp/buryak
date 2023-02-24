import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'recipes_list_card.dart';
import '../model/recipe.dart';

class RecipesList extends StatelessWidget {
  final List<RecordModel> recipes;
  final bool isFavorite;
  const RecipesList(this.recipes, {super.key, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return ListView.builder(
          physics: const ScrollPhysics(),
          itemCount: recipes.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => context.pushNamed('recipe', params: {'recipeId': recipes[index].id}),
                child: RecipeCard(recipes[index].id, Recipe.fromJson(recipes[index].data), isFavorite: isFavorite),
              ),
            );
          },
        );
      } else {
        return MasonryGridView.count(
          physics: const ScrollPhysics(),
          crossAxisCount: constraints.maxWidth < 900 ? constraints.maxWidth ~/ 300 : constraints.maxWidth ~/ 400,
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          itemCount: recipes.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => context.pushNamed('recipe', params: {'recipeId': recipes[index].id}),
                child: RecipeCard(recipes[index].id, Recipe.fromJson(recipes[index].data), isFavorite: isFavorite),
              ),
            );
          },
        );
      }
    });
  }
}
