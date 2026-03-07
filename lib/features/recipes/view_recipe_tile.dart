import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/repositories/recipe_repository.dart';
import '../../shared/repositories/collection_repository.dart';
import '../../shared/models/collection.dart';

class RecipeTile extends StatefulWidget {
  const RecipeTile(
    this.recipeId,
    this.recipe, {
    super.key,
    required this.isFavorite,
  });

  final String recipeId;
  final Recipe recipe;
  final bool isFavorite;

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  bool saved = false;

  @override
  void initState() {
    super.initState();
    saved = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                ClipRRect(
                  borderRadius: context.shapeLarge,
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withAlpha(200), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.3],
                      ),
                    ),
                    child: widget.recipe.images != null && widget.recipe.images!.isNotEmpty
                        ? Image.network(
                            widget.recipe.images!.last.url ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/images/recipe_placeholder.png', fit: BoxFit.cover),
                          )
                        : Image.asset('assets/images/recipe_placeholder.png', fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => _showCollectionsBottomSheet(context),
                        child: const Icon(Icons.playlist_add, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () async {
                          if (!saved) {
                            await RecipeRepository.save(widget.recipeId);
                          } else {
                            await RecipeRepository.unsave(widget.recipeId);
                          }

                          setState(() {
                            saved = !saved;
                          });
                        },
                        child: Icon(saved ? Icons.bookmark_added : Icons.bookmark_add_outlined, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.recipe.author?.name ?? '',
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                // Spacer(),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 10),
                      const Icon(Icons.timer_outlined),
                      const SizedBox(width: 4),
                      Text(widget.recipe.totalTime.toFormattedDuration()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                                widget.recipe.collections?.any((c) => c.id == collection.id) ?? false;
                            
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
