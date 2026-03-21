import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../features/recipes/controller_recipe.dart';
import '../../../features/recipes/view_collections_bottom_sheet.dart';
import '../../providers/saved.dart';

class RecipeActions extends HookConsumerWidget {
  final String recipeId;

  const RecipeActions({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(recipeIsSavedProvider(recipeId));
    final recipe = ref.watch(recipeControllerProvider(recipeId)).asData?.value;

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
          icon: const Icon(Icons.playlist_add),
          tooltip: 'Add to Cookbook',
          onPressed: recipe == null
              ? null
              : () => showCollectionsBottomSheet(
                  context,
                  ref,
                  recipeId: recipeId,
                  initialCollections: recipe.collections,
                ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(isSaved ? Icons.bookmark_added : Icons.bookmark_add_outlined),
          tooltip: isSaved ? 'Unsave' : 'Save',
          onPressed: () async {
            final wasSaved = isSaved;
            try {
              await ref.read(recipeControllerProvider(recipeId).notifier).toggleSaved();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(wasSaved ? 'Recipe removed' : 'Recipe saved'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update saved status')),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
