import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/recipes/author_line.dart';
import '../../shared/components/recipes/placeholder.dart';
import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';
import 'controller_recipe.dart';
import 'dialog_select_collections.dart';

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

    final collections = useState(recipe.collections);
    useEffect(() {
      collections.value = recipe.collections;
      return null;
    }, [recipe.collections]);

    final isCollected = collections.value?.isNotEmpty ?? false;

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
                            colors: [
                              Colors.black.withValues(alpha: 200 / 255),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 0.3],
                          ),
                        ),
                        child: () {
                          if (recipe.imageUrl == null) {
                            return const RecipePlaceholder();
                          }
                          return CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
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
                        onPressed: () async {
                          final updated = await showCollectionsBottomSheet(
                            context,
                            ref,
                            recipeId: recipeId,
                            initialCollections: collections.value,
                          );
                          if (updated != null) collections.value = updated;
                        },
                        icon: Icon(
                          isCollected ? Icons.collections_bookmark : Icons.bookmark_add_outlined,
                          color: Colors.white,
                        ),
                        tooltip: isCollected ? 'Unsave' : 'Save',
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () async {
                          try {
                            await toggle();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to update liked status')),
                              );
                            }
                          }
                        },
                        icon: Icon(isSaved ? Icons.favorite : Icons.favorite_outline, color: Colors.white),
                        tooltip: isSaved ? 'Dislike' : 'Like',
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
                        style: context.textTheme.titleMedium,
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
