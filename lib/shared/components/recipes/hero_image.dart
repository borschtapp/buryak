import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import 'placeholder.dart';

/// A Hero-wrapped recipe image shared between mobile and desktop views.
///
/// [borderRadius] clips the image (desktop uses rounded corners; mobile is full-bleed).
/// [overlay] is positioned at bottom-left, used by mobile for the rating badge.
class RecipeHeroImage extends StatelessWidget {
  const RecipeHeroImage({
    super.key,
    required this.recipe,
    required this.height,
    this.borderRadius,
    this.overlay,
  });

  final Recipe recipe;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Semantics(
      label: 'Photo of ${recipe.name}',
      excludeSemantics: true,
      child: recipe.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: recipe.imageUrl!,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => RecipePlaceholder(height: height),
            )
          : RecipePlaceholder(height: height),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    final hero = Hero(tag: 'recipe_detail_${recipe.id}', child: imageWidget);

    if (overlay == null) return hero;

    return Stack(
      children: [
        hero,
        Positioned(bottom: 16, left: 16, child: overlay!),
      ],
    );
  }
}
