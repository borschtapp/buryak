import 'package:flutter/material.dart';
import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/repositories/recipe_repository.dart';
import '../../shared/providers/collection_notifier.dart';
import '../../shared/views/async_loader.dart';
import 'view_saved_tabs.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late Future<List<Recipe>> _recipesFuture;
  late Future<List<Collection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = RecipeRepository.findAll(preload: 'images,collections,saved,publisher');
    _collectionsFuture = CollectionRepository.findAll(preload: 'recipes:5,recipes.images,total_recipes');

    CollectionRefreshNotifier().addListener(_onCollectionRefresh);
  }

  @override
  void dispose() {
    CollectionRefreshNotifier().removeListener(_onCollectionRefresh);
    super.dispose();
  }

  void _onCollectionRefresh() {
    setState(() {
      _collectionsFuture = CollectionRepository.findAll(preload: 'recipes:5,recipes.images,total_recipes');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Recipes'),
              Tab(text: 'Cookbooks'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AsyncLoader<List<Recipe>>(
                  future: _recipesFuture,
                  builder: (context, recipes) {
                    return SavedRecipesTab(recipes: recipes);
                  },
                ),
                AsyncLoader<List<Collection>>(
                  future: _collectionsFuture,
                  builder: (context, collections) {
                    return SavedCookbooksTab(collections: collections);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
