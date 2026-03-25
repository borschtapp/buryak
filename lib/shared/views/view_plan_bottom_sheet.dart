import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/planner/screen_planner.dart';
import '../extensions.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../repositories/meal_plan_repository.dart';

class PlanBottomSheet extends HookConsumerWidget {
  final Recipe? recipe;
  final MealPlan? plan;

  const PlanBottomSheet({super.key, this.recipe, this.plan})
      : assert(recipe != null || plan != null, 'Must provide either recipe or plan');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = plan != null;
    final selectedDate = useState(plan?.date ?? DateTime.now());
    final selectedMealType = useState(plan?.mealType ?? MealType.lunch);
    final servings = useState(plan?.servings ?? recipe?.yield ?? 1);
    final isSaving = useState(false);

    final mealTypes = MealType.values;

    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: isEditing ? DateTime.now().subtract(const Duration(days: 365)) : DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null && picked != selectedDate.value) {
        selectedDate.value = picked;
      }
    }

    Future<void> save() async {
      isSaving.value = true;
      try {
        if (isEditing) {
          await ref.read(mealPlanRepositoryProvider).update(
                plan!.id,
                date: selectedDate.value,
                mealType: selectedMealType.value,
                servings: servings.value,
              );
        } else {
          await ref.read(mealPlanRepositoryProvider).create(
                selectedDate.value,
                selectedMealType.value,
                recipeId: recipe!.id,
                servings: servings.value,
              );
        }
        ref.invalidate(mealPlanWeekProvider);

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'Meal plan updated' : 'Added to meal plan')),
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

    final title = isEditing ? 'Edit ${plan!.recipe?.name ?? plan!.description ?? 'Meal'}' : 'Add to plan';
    final buttonText = isEditing ? 'Save changes' : 'Add to plan';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: context.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
              ),
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
                : Text(buttonText),
          ),
        ],
      ),
    );
  }
}
