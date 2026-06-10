import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/components/recipes/dialog_select_collections.dart';
import '../../shared/providers/saved.dart';
import '../../shared/util/extensions.dart';
import 'controller_recipe.dart';

class RecipeActions extends HookConsumerWidget {
  final String recipeId;

  const RecipeActions({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(recipeIsSavedProvider(recipeId));
    final recipe = ref.watch(recipeControllerProvider(recipeId)).value;
    final isCollected = recipe?.collections?.isNotEmpty ?? false;
    final l10n = context.l10n;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.share),
          tooltip: l10n.recipeShareTooltip,
          onPressed: recipe == null || recipe.sourceUrl == null
              ? null
              : () => SharePlus.instance.share(ShareParams(uri: Uri.parse(recipe.sourceUrl!))),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(isCollected ? Icons.collections_bookmark : Icons.bookmark_add_outlined),
          tooltip: isCollected ? l10n.recipeUnsaveTooltip : l10n.recipeSaveTooltip,
          onPressed: recipe == null
              ? null
              : () async {
                  final updated = await showCollectionsBottomSheet(
                    context,
                    ref,
                    recipeId: recipeId,
                    initialCollections: recipe.collections,
                  );
                  if (updated != null) {
                    ref.read(recipeControllerProvider(recipeId).notifier).updateCollections(updated);
                  }
                },
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(isSaved ? Icons.favorite : Icons.favorite_outline),
          tooltip: isSaved ? l10n.recipeDislikeTooltip : l10n.recipeLikeTooltip,
          onPressed: () async {
            try {
              await ref.read(recipeControllerProvider(recipeId).notifier).toggleSaved();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.recipeLikeFailed)),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
