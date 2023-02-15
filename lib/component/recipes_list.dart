import 'package:flutter/material.dart';

import 'package:borscht/screen/recipe.dart';
import 'package:borscht/model/recipe.dart';

import 'recipes_list_card.dart';

class RecipesList extends StatelessWidget {
  const RecipesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: RecipeModel.demoRecipe.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipePage(
                            recipeModel: RecipeModel.demoRecipe[index],
                          ),
                        )),
                    child: RecipeCard(
                      recipeModel: RecipeModel.demoRecipe[index],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
