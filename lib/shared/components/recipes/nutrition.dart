import 'package:flutter/material.dart';

import '../../models/recipe_nutrition.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';

class Nutrition extends StatelessWidget {
  final RecipeNutrition? nutrition;

  const Nutrition(this.nutrition, {super.key});

  @override
  Widget build(BuildContext context) {
    if (nutrition?.hasData != true) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingContent,
        vertical: UIConstants.paddingMedium,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildNutritionHeader(context),
        const SizedBox(height: UIConstants.paddingMedium),
        _buildNutritionGrid(context),
      ],
    );
  }

  Widget _buildNutritionHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.recipesNutritionTitle,
          style: context.textTheme.titleMedium,
        ),
        if (nutrition?.servingSize != null && nutrition!.servingSize!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            context.l10n.recipesNutritionPerServing(nutrition!.servingSize!),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNutritionGrid(BuildContext context) {
    final items = _getNutritionItems(context);
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _buildNutritionItem(context, items[i])),
            const SizedBox(width: 12),
            Expanded(
              child: i + 1 < items.length ? _buildNutritionItem(context, items[i + 1]) : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < items.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }

  Widget _buildNutritionItem(BuildContext context, NutritionItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: context.shapeSmall,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<NutritionItem> _getNutritionItems(BuildContext context) {
    final l10n = context.l10n;
    final items = <NutritionItem>[];

    if (nutrition?.calories != null) {
      items.add(NutritionItem(l10n.recipesNutritionCalories, '${nutrition!.calories!.toInt()} kcal'));
    }

    if (nutrition?.protein != null) {
      items.add(NutritionItem(l10n.recipesNutritionProtein, '${nutrition!.protein!.toStringAsFixed(1)}g'));
    }

    if (nutrition?.fat != null) {
      items.add(NutritionItem(l10n.recipesNutritionFat, '${nutrition!.fat!.toStringAsFixed(1)}g'));
    }

    if (nutrition?.carbs != null) {
      items.add(NutritionItem(l10n.recipesNutritionCarbs, '${nutrition!.carbs!.toStringAsFixed(1)}g'));
    }

    if (nutrition?.fatSaturated != null) {
      items.add(NutritionItem(l10n.recipesNutritionSaturatedFat, '${nutrition!.fatSaturated!.toStringAsFixed(1)}g'));
    }

    if (nutrition?.carbsFiber != null) {
      items.add(NutritionItem(l10n.recipesNutritionFiber, '${nutrition!.carbsFiber!.toStringAsFixed(1)}g'));
    }

    if (nutrition?.carbsSugar != null) {
      items.add(NutritionItem(l10n.recipesNutritionSugar, '${nutrition!.carbsSugar!.toStringAsFixed(1)}g'));
    }

    if (nutrition?.sodium != null) {
      items.add(NutritionItem(l10n.recipesNutritionSodium, '${nutrition!.sodium!.toStringAsFixed(0)}mg'));
    }

    return items;
  }
}

class NutritionItem {
  final String label;
  final String value;

  NutritionItem(this.label, this.value);
}
