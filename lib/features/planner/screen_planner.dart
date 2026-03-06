import 'package:flutter/material.dart';

import '../../shared/extensions.dart';
import '../../shared/models/meal_plan.dart';
import '../../shared/repositories/meal_plan_repository.dart';
import '../../shared/views/async_loader.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late Future<List<MealPlan>> _mealPlanFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(const Duration(days: 6));
    _mealPlanFuture = MealPlanRepository.findAll(
      from: from.toIso8601String().substring(0, 10),
      to: to.toIso8601String().substring(0, 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<MealPlan>>(
      future: _mealPlanFuture,
      builder: (context, entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No meals planned this week.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (context, _) => const Divider(),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(entry.recipe?.name ?? entry.note ?? 'Meal'),
              subtitle: Text('${entry.date} · ${entry.mealType}'),
              trailing: Text(
                '${entry.servings ?? 1} serving${(entry.servings ?? 1) == 1 ? '' : 's'}',
                style: context.textTheme.bodySmall,
              ),
            );
          },
        );
      },
    );
  }
}
