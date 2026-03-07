import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/collection.dart';
import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/repositories/collection_repository.dart';

class ProfileRecipesTab extends StatelessWidget {
  final List<Recipe> recipes;

  const ProfileRecipesTab({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const Center(
        child: Text('No recipes yet.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
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
                    recipe.images!.first.url ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/recipe_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Image.asset('assets/images/recipe_placeholder.png', fit: BoxFit.cover),
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
  final List<Collection> collections;

  const ProfileCookbooksTab({super.key, required this.collections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollectionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Cookbook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: collections.isEmpty
            ? const Center(child: Text('No cookbooks yet.'))
            : GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 16 / 9,
                ),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        GoRouter.of(context).goNamed(
                          'collection',
                          pathParameters: {'cid': collection.id},
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.collections, size: 48, color: Colors.grey),
                            ),
                          ),
                          Positioned.fill(child: Container(color: Colors.black26)),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  collection.name,
                                  style: context.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${collection.totalRecipes ?? 0} recipes',
                                  style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz, color: Colors.white),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _confirmDelete(context, collection);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Cookbook'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'My Favorite Recipes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  await CollectionRepository.create(controller.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Collection collection) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cookbook?'),
        content: Text('Are you sure you want to delete "${collection.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await CollectionRepository.delete(collection.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
