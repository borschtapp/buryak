import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/extensions.dart';

class Ingredients extends StatelessWidget {
  final List<RecipeIngredient> ingredients;
  final List<String>? equipment;

  const Ingredients(this.ingredients, {this.equipment, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (equipment != null && equipment!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Equipment', style: context.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: equipment!.map((e) => _buildEquipmentItem(context, _getEquipmentIcon(e), e)).toList(),
                ),
              ],
            ),
          ),
          const Divider(),
        ],

        // Portions & Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ingredients', style: context.textTheme.titleMedium),
            ],
          ),
        ),

        ...ingredients.map((e) => _buildIngredientRow(context, e)),
      ],
    );
  }

  Widget _buildEquipmentItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(label, style: context.textTheme.bodySmall),
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
              ingredient.food?.name ?? ingredient.rawText ?? ingredient.note ?? '',
              style: context.textTheme.bodyLarge,
            ),
          ),
          Text(
            "${ingredient.amount ?? ''} ${ingredient.unit?.name ?? ''}",
            style: context.textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientIcon(BuildContext context, RecipeIngredient ingredient) {
    final icon = ingredient.food?.icon;
    if (icon != null && icon.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: icon,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Icon(Icons.shopping_basket_outlined, color: context.colors.onSurfaceVariant.withAlpha(150), size: 18),
        ),
      );
    }

    return Icon(Icons.shopping_basket_outlined, color: context.colors.onSurfaceVariant.withAlpha(150), size: 20);
  }
}
