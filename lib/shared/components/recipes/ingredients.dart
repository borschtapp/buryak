import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../models/recipe_ingredient.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import '../standard_picture.dart';

class Ingredients extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  final List<Equipment>? equipment;
  final double scale;
  final Widget? headerTrailing;
  final bool showHeader;

  const Ingredients(this.ingredients, {this.equipment, this.scale = 1.0, this.headerTrailing, this.showHeader = true, super.key});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty && (equipment == null || equipment!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final hasEquipment = equipment != null && equipment!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasEquipment) ...[
          _buildEquipmentSection(context),
          const Divider(),
        ],
        if (showHeader) _buildIngredientsHeader(context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingContent),
          child: Column(
            children: [for (final ingredient in ingredients) _buildIngredientRow(context, ingredient)],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.paddingMedium,
        horizontal: UIConstants.paddingContent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equipment',
            style: context.textTheme.titleMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: UIConstants.paddingMedium,
            runSpacing: UIConstants.paddingMedium,
            children: [for (final e in equipment!) _buildEquipmentItem(context, e)],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.paddingMedium,
        horizontal: UIConstants.paddingContent,
      ),
      child: Row(
        children: [
          Text(context.l10n.recipesIngredients, style: context.textTheme.titleMedium),
          if (headerTrailing != null) ...[
            const Spacer(),
            headerTrailing!,
          ],
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(BuildContext context, Equipment equipment) {
    return Column(
      children: [
        StandardPicture(
          imageUrl: equipment.imageUrl,
          fallbackIcon: _getEquipmentIcon(equipment.name),
          size: 64,
          shape: PictureShape.rounded,
          backgroundColor: Colors.transparent,
          border: Border.all(color: context.colors.outline),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Text(
            equipment.name,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getEquipmentIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('oven')) return Icons.kitchen;
    if (lower.contains('microwave')) return Icons.microwave;
    if (lower.contains('kettle')) return Icons.local_drink;
    if (lower.contains('pan') || lower.contains('pot') || lower.contains('skillet')) return Icons.soup_kitchen;
    if (lower.contains('blender') || lower.contains('mixer')) return Icons.blender;
    if (lower.contains('scale')) return Icons.scale;
    if (lower.contains('knife')) return Icons.restaurant;
    return Icons.kitchen;
  }

  Widget _buildIngredientRow(BuildContext context, RecipeIngredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingSmall),
      child: Row(
        children: [
          StandardPicture(
            imageUrl: ingredient.food?.imageUrl,
            fallbackIcon: Icons.shopping_basket_outlined,
            size: 40,
            shape: PictureShape.circle,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Text(
              ingredient.displayName,
              style: context.textTheme.bodyLarge,
            ),
          ),
          Text(
            ingredient.displayScaledAmount(scale),
            style: context.textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
