import 'package:flutter/material.dart';
import '../../shared/models/recipe.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/repositories/shopping_list_repository.dart';
import '../../shared/extensions.dart';

class AddToShoppingBottomSheet extends StatefulWidget {
  final Recipe recipe;

  const AddToShoppingBottomSheet({super.key, required this.recipe});

  @override
  State<AddToShoppingBottomSheet> createState() => _AddToShoppingBottomSheetState();
}

class _AddToShoppingBottomSheetState extends State<AddToShoppingBottomSheet> {
  final Set<String> _selectedIngredientIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Select all ingredients by default
    if (widget.recipe.ingredients != null) {
      for (final ingredient in widget.recipe.ingredients!) {
        _selectedIngredientIds.add(ingredient.id);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final selectedIngredients = widget.recipe.ingredients
          ?.where((i) => _selectedIngredientIds.contains(i.id))
          .toList();

      if (selectedIngredients != null) {
        for (final ingredient in selectedIngredients) {
          final name = ingredient.food?.name ?? ingredient.rawText ?? ingredient.note ?? 'Unknown ingredient';
          await ShoppingListRepository.create(
            name,
            quantity: ingredient.amount,
            unitId: ingredient.unitId,
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredients added to shopping list')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.recipe.ingredients ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add to shopping', style: context.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          if (ingredients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No ingredients found for this recipe.'),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  final name = ingredient.food?.name ?? ingredient.rawText ?? ingredient.note ?? '';
                  final amount = "${ingredient.amount ?? ''} ${ingredient.unit?.name ?? ''}".trim();

                  return CheckboxListTile(
                    value: _selectedIngredientIds.contains(ingredient.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedIngredientIds.add(ingredient.id);
                        } else {
                          _selectedIngredientIds.remove(ingredient.id);
                        }
                      });
                    },
                    title: Text(name),
                    subtitle: amount.isNotEmpty ? Text(amount) : null,
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: _isSaving || _selectedIngredientIds.isEmpty ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add to list'),
            ),
          ),
        ],
      ),
    );
  }
}
