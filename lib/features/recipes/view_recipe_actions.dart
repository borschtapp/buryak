import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/repositories/recipe_repository.dart';
import '../../shared/models/recipe.dart';
import 'view_collections_bottom_sheet.dart';

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
          onPressed: recipe == null
              ? null
              : () => showCollectionsBottomSheet(
                    context,
                    recipeId: widget.recipeId,
                    initialCollections: recipe?.collections,
                  ),
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

}
