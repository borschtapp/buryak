import 'package:flutter/material.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/meal_plan_repository.dart';
import '../../shared/extensions.dart';
import 'package:intl/intl.dart';

class AddToPlanBottomSheet extends StatefulWidget {
  final Recipe recipe;

  const AddToPlanBottomSheet({super.key, required this.recipe});

  @override
  State<AddToPlanBottomSheet> createState() => _AddToPlanBottomSheetState();
}

class _AddToPlanBottomSheetState extends State<AddToPlanBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'lunch';
  int _servings = 1;
  bool _isSaving = false;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.yield ?? 1;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      await MealPlanRepository.create(
        dateStr,
        _selectedMealType,
        recipeId: widget.recipe.id,
        servings: _servings,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to meal plan')),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add to plan', style: context.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date'),
            subtitle: Text(DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          Text('Meal Type', style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: _mealTypes.map((type) => ButtonSegment<String>(
              value: type,
              label: Text(type[0].toUpperCase() + type.substring(1)),
            )).toList(),
            selected: {_selectedMealType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedMealType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Servings', style: context.textTheme.titleSmall),
              const Spacer(),
              IconButton(
                onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
                icon: const Icon(Icons.remove),
              ),
              Text('$_servings', style: context.textTheme.titleMedium),
              IconButton(
                onPressed: () => setState(() => _servings++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Add to plan'),
          ),
        ],
      ),
    );
  }
}
