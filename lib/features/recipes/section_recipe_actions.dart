import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/components/recipes/dialog_select_collections.dart';
import '../../shared/providers/saved.dart';
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: recipe == null
              ? null
              : () {
                  final text = 'Check out this recipe: ${recipe.name}\n${recipe.url ?? ""}';
                  SharePlus.instance.share(ShareParams(text: text));
                },
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(isCollected ? Icons.collections_bookmark : Icons.bookmark_add_outlined),
          tooltip: isCollected ? 'Unsave' : 'Save',
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
          tooltip: isSaved ? 'Dislike' : 'Like',
          onPressed: () async {
            try {
              await ref.read(recipeControllerProvider(recipeId).notifier).toggleSaved();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update liked status')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
