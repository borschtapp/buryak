import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../model/recipe.dart';
import '../service/user.dart';
import '../widget/async_loader.dart';

class RecipeScreen extends StatefulWidget {
  final String recipeId;

  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late Future<Recipe> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = UserService.pb.collection('recipes').getOne(widget.recipeId)
        .then((model) => Recipe.fromJson(model.data));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final text = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context),
      body: AsyncLoader<Recipe>(
        future: _recipeFuture,
        builder: (context, recipe) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: widget.recipeId,
                  child: Image(
                    height: max(size.height / 3, 200),
                    fit: BoxFit.cover,
                    image: NetworkImage(recipe.image != null ? recipe.image!.last.url! : 'https://i.imgur.com/IRAxUoq.jpg'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              recipe.name!,
                              style: text.titleLarge,
                            ),
                          ),
                          if (recipe.aggregateRating != null && recipe.aggregateRating!.ratingValue != null) Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: color.primary, borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                    Text(recipe.aggregateRating!.ratingValue!.toString(), style: const TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (recipe.publisher != null || recipe.author != null) InkWell(
                        onTap: () => {
                          if (recipe.author != null && recipe.author!.url != null) {
                            launchUrlString(recipe.author!.url!)
                          } else if (recipe.publisher != null && recipe.publisher!.url != null) {
                            launchUrlString(recipe.publisher!.url!)
                          }
                        },
                        child: Text(
                          recipe.getCombinedAuthor() ?? '',
                          style: text.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "198",
                            // style: _textTheme.caption,
                          ),
                          const SizedBox(width: 20),
                          const Icon(Icons.timer),
                          const SizedBox(width: 4),
                          Text('${recipe.cookTime!}\''),
                          const SizedBox(width: 20),
                          Container(
                            width: 1,
                            height: 30,
                            color: color.secondary,
                          ),
                          const SizedBox(width: 20),
                          Text('${recipe.recipeYield!} Servings'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Divider(color: color.secondary),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          "Ingredients",
                          style: text.titleMedium,
                        ),
                      ),
                      Ingredients(recipe.recipeIngredient!),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          "Preparation",
                          style: text.titleMedium,
                        ),
                      ),
                      Instructions(recipe.recipeInstructions!),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 36),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed('home');
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined, size: 36),
          onPressed: () {},
        ),
        const SizedBox(width: 5)
      ],
    );
  }
}

class Ingredients extends StatelessWidget {
  final List<String> ingredients;
  const Ingredients(this.ingredients, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (BuildContext context, int index) {
        return Text(ingredients[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), height: 15);
      },
    );
  }
}

class Instructions extends StatelessWidget {
  final List<HowToSection> instructions;
  const Instructions(this.instructions, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: instructions.length,
      itemBuilder: (BuildContext context, int index) {
        return Text(instructions[index].text!);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), height: 15);
      },
    );
  }
}
