import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/components/loading_button.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/models/recipe.dart';
import '../../shared/repositories/meal_plan_repository.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import 'notifier_planner.dart';

class PlanBottomSheet extends HookConsumerWidget {
  final Recipe? recipe;
  final MealPlan? plan;

  const PlanBottomSheet({super.key, this.recipe, this.plan}) : assert(recipe != null || plan != null, 'Must provide either recipe or plan');

  static final List<ButtonSegment<MealType>> _mealTypeSegments = MealType.values
      .map(
        (type) => ButtonSegment<MealType>(
          value: type,
          label: Text(type.name.capitalize()),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = plan != null;
    final selectedDate = useState(plan?.date ?? DateTime.now());
    final selectedMealType = useState(plan?.mealType ?? MealType.lunch);
    final servings = useState(plan?.servings ?? recipe?.yield ?? 1);
    final isSaving = useState(false);

    Future<void> selectDate() async {
      final now = DateTime.now();
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: isEditing ? now.subtract(const Duration(days: 365)) : now,
        lastDate: now.add(const Duration(days: 365)),
      );
      if (picked != null && picked != selectedDate.value) {
        selectedDate.value = picked;
      }
    }

    Future<void> save() async {
      isSaving.value = true;
      try {
        final updated = isEditing
            ? await ref
                  .read(mealPlanRepositoryProvider)
                  .update(
                    plan!.id,
                    date: selectedDate.value,
                    mealType: selectedMealType.value,
                    servings: servings.value,
                  )
            : await ref
                  .read(mealPlanRepositoryProvider)
                  .create(
                    selectedDate.value,
                    selectedMealType.value,
                    recipeId: recipe!.id,
                    servings: servings.value,
                  );

        // Update local state instead of re-fetching the entire week
        final notifier = ref.read(mealPlanWeekProvider.notifier);
        if (isEditing) {
          notifier.updatePlan(updated);
        } else {
          notifier.addPlan(updated);
        }

        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'Meal plan updated' : 'Added to meal plan')),
          );
        }
      } catch (e) {
        ref.handleException(e);
      } finally {
        if (context.mounted) {
          isSaving.value = false;
        }
      }
    }

    final title = isEditing ? 'Edit ${plan!.recipe?.name ?? plan!.description ?? 'Meal'}' : 'Add to plan';
    final buttonText = isEditing ? 'Save changes' : 'Add to plan';

    return StandardBottomSheet(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            segments: _mealTypeSegments,
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
          LoadingButton(
            isLoading: isSaving.value,
            onPressed: save,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
