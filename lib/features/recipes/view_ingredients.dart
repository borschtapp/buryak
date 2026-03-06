import 'package:flutter/material.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/extensions.dart';

class Ingredients extends StatelessWidget {
  final List<RecipeIngredient> ingredients;

  const Ingredients(this.ingredients, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Equipment Placeholder (Static as per screenshot suggestion)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Equipment', style: context.textTheme.titleMedium?.copyWith(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildEquipmentItem(context, Icons.kitchen, 'Oven'),
                  const SizedBox(width: 16),
                  _buildEquipmentItem(context, Icons.local_drink, 'Kettle'),
                ],
              ),
            ],
          ),
        ),
        const Divider(),

        // Portions & Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ingredients', style: context.textTheme.titleMedium),
              // TextButton(
              //     onPressed: () {}, child: const Text("Convert Units", style: TextStyle(color: Colors.pinkAccent))),
            ],
          ),
        ),

        // Portion Counter
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   decoration: BoxDecoration(
        //     border: Border.all(color: Colors.white24),
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () {}),
        //       Text("4 Portions", style: context.textTheme.titleMedium),
        //       IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {}),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 16),
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

  Widget _buildIngredientRow(BuildContext context, RecipeIngredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.green, // Placeholder color for icon
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.egg_alt, color: Colors.white), // Generic icon
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
}
