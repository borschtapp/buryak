import 'package:flutter/material.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/views/async_loader.dart';
import '../recipes/view_recipes_grid.dart';

class CollectionScreen extends StatefulWidget {
  final String collectionId;

  const CollectionScreen({super.key, required this.collectionId});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late Future<Collection> _collectionFuture;
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _collectionFuture = CollectionRepository.findOne(widget.collectionId);
    _recipesFuture = CollectionRepository.getRecipes(
      widget.collectionId,
      preload: 'publisher,feed,images,ingredients,instructions,taxonomies,collections,saved',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AsyncLoader<Collection>(
            future: _collectionFuture,
            builder: (context, collection) {
              return Text(
                collection.name,
                style: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
        ),
        Expanded(
          child: AsyncLoader<List<Recipe>>(
            future: _recipesFuture,
            builder: (context, recipes) {
              if (recipes.isEmpty) {
                return const Center(child: Text('No recipes in this cookbook yet.'));
              }
              return RecipesGridView(recipes, isFavorite: false);
            },
          ),
        ),
      ],
    );
  }
}
