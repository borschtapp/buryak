import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/recipe.dart';
import '../../extensions.dart';
import '../../widgets/recipe_author_line.dart';
import '../../widgets/recipe_placeholder.dart';
import '../../../features/recipes/controller_recipe.dart';
import '../../../features/recipes/view_collections_bottom_sheet.dart';

class RecipeTile extends HookConsumerWidget {
  const RecipeTile({
    required this.recipe,
    super.key,
  });

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeId = recipe.id;
    final (:isSaved, :toggle) = useSavedRecipe(
      recipeId: recipeId,
      ref: ref,
    );

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
                  child: Hero(
                    tag: 'recipe_tile_${recipe.id}',
                    child: Semantics(
                      label: 'Photo of ${recipe.name}',
                      excludeSemantics: true,
                      child: Container(
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withAlpha(200), Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 0.3],
                          ),
                        ),
                        child: () {
                          final imageUrl = recipe.primaryImageUrl;
                          if (imageUrl == null) {
                            return const RecipePlaceholder();
                          }
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const RecipePlaceholder(),
                          );
                        }(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => showCollectionsBottomSheet(
                          context,
                          ref,
                          recipeId: recipeId,
                          initialCollections: recipe.collections,
                        ),
                        icon: const Icon(Icons.playlist_add, color: Colors.white),
                        tooltip: 'Add to Cookbook',
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () async {
                          try {
                            await toggle();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to update saved status')),
                              );
                            }
                          }
                        },
                        icon: Icon(isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined, color: Colors.white),
                        tooltip: isSaved ? 'Remove from Saved' : 'Save Recipe',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      RecipeAuthorLine(recipe: recipe, showPrefix: false, useUnderline: false),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Semantics(
                    label: 'Total time: ${recipe.totalTime.toFormattedDuration()}',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.timer_outlined, semanticLabel: 'Time'),
                        const SizedBox(width: 4),
                        Text(recipe.totalTime.toFormattedDuration()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
