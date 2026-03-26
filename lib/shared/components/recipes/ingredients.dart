import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/equipment.dart';
import '../../models/recipe_ingredient.dart';
import '../../util/extensions.dart';

class Ingredients extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  final List<Equipment>? equipment;

  const Ingredients(this.ingredients, {this.equipment, super.key});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty && (equipment == null || equipment!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final hasEquipment = equipment != null && equipment!.isNotEmpty;
    // Header slots: [equipment, divider, title] when equipment present, else [title]
    final headerCount = hasEquipment ? 3 : 1;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: headerCount + ingredients.length,
      itemBuilder: (context, index) {
        if (hasEquipment) {
          if (index == 0) return _buildEquipmentSection(context);
          if (index == 1) return const Divider();
          if (index == 2) return _buildIngredientsHeader(context);
          return _buildIngredientRow(context, ingredients[index - 3]);
        } else {
          if (index == 0) return _buildIngredientsHeader(context);
          return _buildIngredientRow(context, ingredients[index - 1]);
        }
      },
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equipment',
            style: context.textTheme.titleMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: equipment!.map((e) => _buildEquipmentItem(context, e)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text('Ingredients', style: context.textTheme.titleMedium),
    );
  }

  Widget _buildEquipmentItem(BuildContext context, Equipment equipment) {
    final imageUrl = equipment.imageUrl;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.outline),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: imageUrl != null && imageUrl.trim().isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(
                        _getEquipmentIcon(equipment.name),
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  )
                : Semantics(
                    label: equipment.name,
                    child: Icon(
                      _getEquipmentIcon(equipment.name),
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: _buildIngredientIcon(context, ingredient),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              ingredient.displayName,
              style: context.textTheme.bodyLarge,
            ),
          ),
          Text(
            ingredient.displayAmount,
            style: context.textTheme.bodyLarge?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientIcon(BuildContext context, RecipeIngredient ingredient) {
    final icon = ingredient.food?.imageUrl;
    if (icon != null && icon.trim().isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: icon,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Icon(
            Icons.shopping_basket_outlined,
            color: context.colors.onSurfaceVariant.withValues(alpha: 150 / 255),
            size: 18,
          ),
        ),
      );
    }

    return Icon(
      Icons.shopping_basket_outlined,
      color: context.colors.onSurfaceVariant.withValues(alpha: 150 / 255),
      size: 20,
    );
  }
}
