import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/widgets/recipe_author_line.dart';
import '../../shared/widgets/recipe_placeholder.dart';
import '../../shared/ui_constants.dart';
import '../../shared/widgets/recipes/view_ingredients.dart';
import '../../shared/widgets/recipes/view_instructions.dart';

class RecipeDesktopView extends StatelessWidget {
  final Recipe recipe;

  const RecipeDesktopView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? 16 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecipeImage(recipe: recipe),
          const SizedBox(height: 32),
          _RecipeHeader(recipe: recipe),
          const SizedBox(height: 16),
          _RecipeDetailsPanel(recipe: recipe),
          const SizedBox(height: 48),
          _RecipeContentBody(recipe: recipe),
        ],
      ),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final Recipe recipe;

  const _RecipeImage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final image = recipe.primaryImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Hero(
        tag: 'recipe_detail_${recipe.id}',
        child: Semantics(
          label: 'Photo of ${recipe.name}',
          excludeSemantics: true,
          child: image != null
              ? CachedNetworkImage(
                  imageUrl: image,
                  height: UIConstants.recipeMaxImageHeightDesktop,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const RecipePlaceholder(height: UIConstants.recipeMaxImageHeightDesktop),
                )
              : const RecipePlaceholder(height: UIConstants.recipeMaxImageHeightDesktop),
        ),
      ),
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  final Recipe recipe;

  const _RecipeHeader({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RecipeAuthorLine(recipe: recipe, showPrefix: false, useUnderline: false),
        const SizedBox(height: 4),
        if (recipe.published != null)
          Text(
            'Published: ${DateFormat.yMMMd().format(recipe.published!)}',
            style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _RecipeDetailsPanel extends StatelessWidget {
  final Recipe recipe;

  const _RecipeDetailsPanel({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DetailItem(icon: Icons.timer, label: recipe.totalTime.toFormattedDuration()),
        const SizedBox(width: 24),
        if (recipe.yield != null && recipe.yield! > 0) ...[
          const SizedBox(width: 24),
          _DetailItem(icon: Icons.restaurant, label: '${recipe.yield} Servings'),
        ],
        if (recipe.rating?.value != null && recipe.rating!.value! > 0) ...[
          const SizedBox(width: 24),
          _DetailItem(
            icon: Icons.star,
            label: recipe.rating!.value!.toStringAsFixed(1),
            iconColor: Colors.amber,
          ),
        ],
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _DetailItem({required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _RecipeContentBody extends StatelessWidget {
  final Recipe recipe;

  const _RecipeContentBody({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _ContentSection(
            title: 'Ingredients',
            child: Ingredients(recipe.ingredients ?? [], equipment: recipe.equipment),
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          flex: 1,
          child: _ContentSection(
            title: 'Preparation',
            child: Instructions(recipe.instructions ?? []),
          ),
        ),
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ContentSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineSmall),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
