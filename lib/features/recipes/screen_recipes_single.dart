import 'dart:math';

import 'package:buryak/shared/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'view_ingredients.dart';
import 'view_instructions.dart';
import '../../shared/views/article_content.dart';
import '../../shared/models/recipe.dart';
import '../../shared/providers/user.dart';
import '../../shared/views/async_loader.dart';

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
    _recipeFuture = UserService.pb
        .collection('recipes')
        .getOne(widget.recipeId)
        .then((model) => Recipe.fromJson(model.data));
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<Recipe>(
      future: _recipeFuture,
      builder: (context, recipe) {
        return buildBase(context, recipe);
      },
    );
  }

  Widget buildBase(BuildContext context, Recipe recipe) {
    if (context.isMobile) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: mobileAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                recipe.image != null
                    ? recipe.image!.last.url!
                    : 'https://i.imgur.com/IRAxUoq.jpg',
                height: min(context.mediaQuery.size.height * 0.4, 400),
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: recipeCommon(recipe),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: ArticleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    onPressed: () => GoRouter.of(context).go('/recipes'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              buildPage(context, recipe),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: ClipRRect(
            borderRadius: context.shapeSmall,
            child: Image.network(
              recipe.image != null ? recipe.image!.last.url! : 'https://i.imgur.com/IRAxUoq.jpg',
              height: max(context.mediaQuery.size.height / 3, 400),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: recipeCommon(recipe),
        ),
      ],
    );
  }

  Widget recipeHeader(Recipe recipe) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            recipe.name!,
            style: context.textTheme.titleLarge,
          ),
        ),
        if (recipe.aggregateRating != null && recipe.aggregateRating!.ratingValue != null)
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration:
                    BoxDecoration(color: context.colors.primary, borderRadius: context.shapeSmall),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 15,
                      color: Colors.black,
                    ),
                    Text(recipe.aggregateRating!.ratingValue!.toString(),
                        style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget recipeCommon(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        recipeHeader(recipe),
        const SizedBox(height: 8),
        if (recipe.publisher != null || recipe.author != null)
          InkWell(
            onTap: () => {
              if (recipe.author != null && recipe.author!.url != null)
                {launchUrlString(recipe.author!.url!)}
              else if (recipe.publisher != null && recipe.publisher!.url != null)
                {launchUrlString(recipe.publisher!.url!)}
            },
            child: Text(
              recipe.getCombinedAuthor() ?? '',
              style: context.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 10),
        recipeDetails(recipe),
        const SizedBox(height: 4),
        Divider(color: context.colors.secondary),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "Ingredients",
            style: context.textTheme.titleMedium,
          ),
        ),
        Ingredients(recipe.recipeIngredient!),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            "Preparation",
            style: context.textTheme.titleMedium,
          ),
        ),
        Instructions(recipe.recipeInstructions!),
      ],
    );
  }

  Widget recipeDetails(Recipe recipe) {
    return Row(
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
          color: context.colors.secondary,
        ),
        const SizedBox(width: 20),
        Text('${recipe.recipeYield!} Servings'),
      ],
    );
  }

  AppBar mobileAppBar(BuildContext context) {
    return AppBar(
      leading: BackButton(
        onPressed: () => GoRouter.of(context).goNamed('recipes'),
      ),
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient:
              LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [
            0,
            0.5,
            1
          ], colors: <Color>[
            Colors.black.withAlpha(200),
            Colors.black.withAlpha(125),
            Colors.transparent,
          ]),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () {},
        ),
      ],
    );
  }
}
