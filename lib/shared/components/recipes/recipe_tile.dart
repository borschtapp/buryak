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
import 'liked_by_avatars.dart';
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
    final isSaved = ref.watchIsSaved(recipe);
    final likedByOthers = ref.watchLikedByOthers(recipe);
    final totalTime = recipe.totalTime.asDuration?.localized(context.l10n) ?? '-';

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
                      child: recipe.imageUrl == null
                          ? const RecipePlaceholder()
                          : CachedNetworkImage(
                              imageUrl: recipe.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const RecipePlaceholder(),
                            ),
                    ),
                  ),
                ),
                // One translucent pill in the corner gives the icons contrast on any photo,
                // without darkening the photo itself.
                Positioned(
                  top: UIConstants.paddingSmall,
                  right: UIConstants.paddingSmall,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const StadiumBorder(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (likedByOthers.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: UIConstants.paddingSmall),
                            child: LikedByAvatars(users: likedByOthers, ringColor: Colors.white, size: 22),
                          ),
                        IconButton(
                          onPressed: () async {
                            try {
                              await ref.read(recipeSaveTogglesProvider.notifier).toggle(recipeId, isSaved: isSaved);
                            } catch (e) {
                              ref.handleException(e);
                            }
                          },
                          icon: Icon(isSaved ? Icons.favorite : Icons.favorite_outline, color: Colors.white),
                          tooltip: isSaved ? context.l10n.recipeDislikeTooltip : context.l10n.recipeLikeTooltip,
                        ),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 72,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: context.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Semantics(
                      label: context.l10n.recipeTotalTimeLabel(totalTime),
                      child: IconLabel(icon: Icons.timer_outlined, label: totalTime, iconSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: RecipeAuthorLine(recipe: recipe, showPrefix: false, useUnderline: false),
                      ),
                    ),
                    if (recipe.displayDate case final date?)
                      Semantics(
                        label: context.l10n.recipesPublishedDate(date.localizedDate(context.l10n)),
                        excludeSemantics: true,
                        child: Text(
                          date.localizedDate(context.l10n, omitCurrentYear: true),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: recipe.displayDateColor(context.colors),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
