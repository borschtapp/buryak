import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/collection.dart';
import '../../models/recipe.dart';
import '../../providers/saved.dart';
import '../../util/error_extensions.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import '../icon_label.dart';
import 'author_line.dart';
import 'dialog_select_collections.dart';
import 'placeholder.dart';

class RecipeTile extends HookConsumerWidget {
  const RecipeTile({
    required this.recipe,
    super.key,
  });

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeId = recipe.id;
    final (:isSaved, :toggle) = ref.watch(savedRecipeStateProvider(recipeId));

    final collectionsOverride = useState<List<Collection>?>(null);
    useEffect(() {
      collectionsOverride.value = null;
      return null;
    }, [recipe.id]);

    final isCollected = (collectionsOverride.value ?? recipe.collections)?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
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
                              Colors.black.withValues(alpha: 0.78),
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
                            initialCollections: collectionsOverride.value ?? recipe.collections,
                          );
                          if (updated != null) collectionsOverride.value = updated;
                        },
                        icon: Icon(
                          isCollected ? Icons.collections_bookmark : Icons.bookmark_add_outlined,
                          color: Colors.white,
                        ),
                        tooltip: isCollected ? context.l10n.recipeUnsaveTooltip : context.l10n.recipeSaveTooltip,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () async {
                          try {
                            await toggle();
                          } catch (e) {
                            ref.handleException(e);
                          }
                        },
                        icon: Icon(isSaved ? Icons.favorite : Icons.favorite_outline, color: Colors.white),
                        tooltip: isSaved ? context.l10n.recipeLikeTooltip : context.l10n.recipeDislikeTooltip,
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
                    label: context.l10n.recipeTotalTimeLabel(recipe.totalTime.asDuration?.localized(context.l10n) ?? '-'),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconLabel(
                        icon: Icons.timer_outlined,
                        label: recipe.totalTime.asDuration?.localized(context.l10n) ?? '-',
                        iconSize: 16,
                      ),
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
