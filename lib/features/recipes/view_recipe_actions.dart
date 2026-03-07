import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/repositories/recipe_repository.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/collection.dart';

class RecipeActions extends StatefulWidget {
  final String recipeId;
  final Recipe? recipe;

  const RecipeActions({
    super.key,
    required this.recipeId,
    this.recipe,
  });

  @override
  State<RecipeActions> createState() => _RecipeActionsState();
}

class _RecipeActionsState extends State<RecipeActions> {
  bool _isSaved = false;
  Recipe? _loadedRecipe;

  Recipe? get recipe => widget.recipe ?? _loadedRecipe;

  @override
  void initState() {
    super.initState();
    // In a real app, we'd check if it's already saved.
    // For now, matching the tile behavior.
    if (widget.recipe == null) {
      _loadRecipe();
    }
  }

  Future<void> _loadRecipe() async {
    try {
      final recipe = await RecipeRepository.findOne(widget.recipeId);
      if (mounted) {
        setState(() {
          _loadedRecipe = recipe;
        });
      }
    } catch (e) {
      debugPrint('Error loading recipe for actions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: recipe == null
              ? null
              : () {
                  final text = 'Check out this recipe: ${recipe!.name}\n${recipe!.url ?? ""}';
                  SharePlus.instance.share(ShareParams(text: text));
                },
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          tooltip: 'Add to Cookbook',
          onPressed: () => _showCollectionsBottomSheet(context),
        ),
        IconButton(
          icon: Icon(_isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined),
          tooltip: _isSaved ? 'Unsave' : 'Save',
          onPressed: () async {
            try {
              if (_isSaved) {
                await RecipeRepository.unsave(widget.recipeId);
              } else {
                await RecipeRepository.save(widget.recipeId);
              }
              if (!context.mounted) return;
              setState(() {
                _isSaved = !_isSaved;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSaved ? 'Recipe saved' : 'Recipe unsaved'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Failed to update saved status')));
            }
          },
        ),
      ],
    );
  }

  void _showCollectionsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Collection>>(
          future: CollectionRepository.findAll(preload: 'recipes:5,recipes.images,total_recipes'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SizedBox(height: 200, child: Center(child: Text('Error: ${snapshot.error}')));
            }
            final collections = snapshot.data ?? [];
            if (collections.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('No cookbooks found. Create one in Profile.')),
              );
            }

            final Set<String> localAddedId = {};
            final Set<String> localRemovedId = {};

            return StatefulBuilder(
              builder: (context, setSheetState) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Add to Cookbook', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: collections.length,
                          itemBuilder: (context, index) {
                            final collection = collections[index];
                            final originallyInCollection =
                                recipe?.collections?.any((c) => c.id == collection.id) ?? false;
                            
                            final isInCollection = originallyInCollection
                                ? !localRemovedId.contains(collection.id)
                                : localAddedId.contains(collection.id);

                            return ListTile(
                              leading: Icon(
                                isInCollection ? Icons.check_circle : Icons.add_circle_outline,
                                color: isInCollection ? Colors.green : null,
                              ),
                              title: Text(collection.name),
                              onTap: () async {
                                try {
                                  if (isInCollection) {
                                    await CollectionRepository.removeRecipe(collection.id, widget.recipeId);
                                    setSheetState(() {
                                      if (originallyInCollection) {
                                        localRemovedId.add(collection.id);
                                      } else {
                                        localAddedId.remove(collection.id);
                                      }
                                    });
                                  } else {
                                    await CollectionRepository.addRecipe(collection.id, widget.recipeId);
                                    setSheetState(() {
                                      if (originallyInCollection) {
                                        localRemovedId.remove(collection.id);
                                      } else {
                                        localAddedId.add(collection.id);
                                      }
                                    });
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
