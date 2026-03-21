import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/planner/screen_planner.dart';
import '../../shared/extensions.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/meal_plan_repository.dart';

class AddToPlanBottomSheet extends HookConsumerWidget {
  final Recipe recipe;

  const AddToPlanBottomSheet({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final selectedMealType = useState(MealType.lunch);
    final servings = useState(recipe.yield ?? 1);
    final isSaving = useState(false);

    final mealTypes = MealType.values;

    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null && picked != selectedDate.value) {
        selectedDate.value = picked;
      }
    }

    Future<void> save() async {
      isSaving.value = true;
      try {
        await ref
            .read(mealPlanRepositoryProvider)
            .create(
              selectedDate.value,
              selectedMealType.value,
              recipeId: recipe.id,
              servings: servings.value,
            );
        ref.invalidate(mealPlanWeekProvider);

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to meal plan')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

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
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Focus(
            autofocus: true,
            child: ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEEE, MMMM d, yyyy').format(selectedDate.value)),
              trailing: const Icon(Icons.calendar_today),
              onTap: selectDate,
            ),
          ),
          const SizedBox(height: 16),
          Text('Meal Type', style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<MealType>(
            segments: mealTypes
                .map(
                  (type) => ButtonSegment<MealType>(
                    value: type,
                    label: Text(type.name.capitalize()),
                  ),
                )
                .toList(),
            selected: {selectedMealType.value},
            onSelectionChanged: (Set<MealType> newSelection) {
              selectedMealType.value = newSelection.first;
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Servings', style: context.textTheme.titleSmall),
              const Spacer(),
              IconButton(
                onPressed: servings.value > 1 ? () => servings.value-- : null,
                icon: const Icon(Icons.remove),
                tooltip: 'Decrease servings',
              ),
              Text('${servings.value}', style: context.textTheme.titleMedium),
              IconButton(
                onPressed: servings.value < 99 ? () => servings.value++ : null,
                icon: const Icon(Icons.add),
                tooltip: 'Increase servings',
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: isSaving.value ? null : save,
            child: isSaving.value
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
