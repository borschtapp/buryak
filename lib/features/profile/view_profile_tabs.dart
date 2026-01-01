import 'package:flutter/material.dart';

import '../../shared/models/cookbook.dart';
import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';

class ProfileRecipesTab extends StatelessWidget {
  final List<Recipe> recipes; // You might want to pass this or fetch it

  const ProfileRecipesTab({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const Center(child: Text("No recipes yet."));
    }

    // We can reuse the existing RecipesGridView or create a similar one here
    // For now, let's build a simple adaptive grid to demonstrate the layout.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // Compact cards
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (recipe.images != null && recipe.images!.isNotEmpty)
                  Image.network(
                    recipe.images!.first.url,
                    fit: BoxFit.cover,
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    child: Text(
                      recipe.name,
                      style: context.textTheme.titleSmall?.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileCookbooksTab extends StatelessWidget {
  final List<Cookbook> cookbooks;

  const ProfileCookbooksTab({super.key, required this.cookbooks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300, // Wider cards for cookbooks
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 16 / 9,
        ),
        itemCount: cookbooks.length,
        itemBuilder: (context, index) {
          final book = cookbooks[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    book.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                    child: Container(
                  color: Colors.black26,
                )),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        book.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${book.recipesCount} recipes",
                        style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.more_horiz, color: Colors.white),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
