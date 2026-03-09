import 'package:flutter/material.dart';
import '../../shared/models/collection.dart';
import '../../shared/models/user.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/repositories/recipe_repository.dart';
import 'view_profile_details.dart';
import 'view_profile_tabs.dart';
import '../../shared/providers/user.dart';
import '../../shared/providers/collection_notifier.dart';
import '../../shared/views/async_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    User profile;
    try {
      profile = UserService.getUserModel();
    } catch (e) {
      return const Center(child: Text('User not found. Please log in again.'));
    }

    String? name = profile.name;
    String email = profile.email;
    String? image = profile.image;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          ProfileDetails(name: name, email: email, image: image),
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
                    return ProfileRecipesTab(recipes: recipes);
                  },
                ),
                AsyncLoader<List<Collection>>(
                  future: _collectionsFuture,
                  builder: (context, collections) {
                    return ProfileCookbooksTab(collections: collections);
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
