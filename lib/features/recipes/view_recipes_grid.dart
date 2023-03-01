import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import 'view_recipe_tile.dart';

class RecipesGridView extends StatelessWidget {
  final List<RecordModel> recipes;
  final bool isFavorite;
  const RecipesGridView(this.recipes, {super.key, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GridView.builder(
        padding: const EdgeInsets.all(5),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.isMobile ? constraints.maxWidth ~/ 300 : constraints.maxWidth ~/ 350,
          childAspectRatio: constraints.isMobile ? 1.2 : 1.1,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = Recipe.fromJson(recipes[index].data);
          return InkWell(
            borderRadius: context.shapeSmall,
            child: RecipeTile(recipes[index].id, recipe, isFavorite: isFavorite),
            onTap: () => GoRouter.of(context).pushNamed('recipe', params: {'rid': recipes[index].id}),
          );
        },
      );
    });
  }
}
