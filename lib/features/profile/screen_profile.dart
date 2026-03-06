import 'package:flutter/material.dart';
import '../../shared/models/collection.dart';
import '../../shared/models/user.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/repositories/recipe_repository.dart';
import 'view_profile_details.dart';
import 'view_profile_tabs.dart';
import '../../shared/providers/user.dart';
import '../../shared/views/async_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<User> _profileFuture = UserService.getUserModel();
  final Future<List<Recipe>> _recipesFuture = RecipeRepository.findAll();
  final Future<List<Collection>> _collectionsFuture = CollectionRepository.findAll();

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<User>(
      future: _profileFuture,
      builder: (context, profile) {
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
      },
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final Icon icon;
  final String label;
  final void Function(BuildContext) onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              icon,
              const SizedBox(width: 20),
              Text(label),
              const Spacer(),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
