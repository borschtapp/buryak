import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/recipe_cost_estimate.dart';
import '../../models/recipe_ingredient.dart';
import '../../providers/household.dart';
import '../../providers/recipe_price.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import '../standard_picture.dart';

class RecipeCost extends ConsumerWidget {
  const RecipeCost({
    super.key,
    required this.recipeId,
    required this.ingredients,
    this.onAddPrice,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final String recipeId;
  final List<RecipeIngredient> ingredients;
  final void Function(RecipeIngredient ingredient)? onAddPrice;
  final void Function(RecipeIngredient ingredient)? onIngredientTap;
  final void Function(RecipeIngredient ingredient)? onIngredientLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimateAsync = ref.watch(recipeCostEstimateProvider(recipeId));
    final household = ref.watch(householdProvider).value;
    final currency = household?.currency;

    return estimateAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(UIConstants.paddingLarge),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.all(UIConstants.paddingContent),
        child: Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(recipeCostEstimateProvider(recipeId)),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.errorTryAgain),
          ),
        ),
      ),
      data: (estimate) {
        return _CostContent(
          estimate: estimate,
          ingredients: ingredients,
          currency: currency,
          onAddPrice: onAddPrice,
          onIngredientTap: onIngredientTap,
          onIngredientLongPress: onIngredientLongPress,
        );
      },
    );
  }
}

class _CostContent extends StatelessWidget {
  const _CostContent({
    required this.estimate,
    required this.ingredients,
    required this.currency,
    this.onAddPrice,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final RecipeCostEstimate estimate;
  final List<RecipeIngredient> ingredients;
  final String? currency;
  final void Function(RecipeIngredient ingredient)? onAddPrice;
  final void Function(RecipeIngredient ingredient)? onIngredientTap;
  final void Function(RecipeIngredient ingredient)? onIngredientLongPress;

  @override
  Widget build(BuildContext context) {
    final formatter = context.currencyFormatter(currency);
    final hasTotal = estimate.total != null;
    final hasPerServing = estimate.perServing != null;
    final hasAnyData = hasTotal || hasPerServing;

    final costByIngredientId = {
      for (final item in estimate.items ?? <RecipeIngredientCost>[]) item.ingredientId: item,
    };

    final actionableIngredients = <RecipeIngredient>[];
    final pricedIngredients = <({RecipeIngredient ingredient, RecipeIngredientCost cost})>[];

    for (final ingredient in ingredients) {
      final cost = costByIngredientId[ingredient.id];
      if (cost == null) continue;
      if (cost.status == IngredientCostStatus.missingPrice || cost.status == IngredientCostStatus.incompatibleUnit) {
        actionableIngredients.add(ingredient);
      } else if (cost.status == IngredientCostStatus.calculated) {
        pricedIngredients.add((ingredient: ingredient, cost: cost));
      }
      // pantry items intentionally omitted from both lists
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingContent,
        vertical: UIConstants.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.l10n.recipeCostTitle, style: context.textTheme.titleMedium),
              if (!estimate.isComplete) ...[
                const SizedBox(width: UIConstants.paddingSmall),
                Chip(
                  label: Text(
                    context.l10n.recipeCostIncomplete(estimate.missingCount),
                    style: context.textTheme.labelSmall,
                  ),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: context.colors.outlineVariant),
                  backgroundColor: context.colors.surfaceContainerHighest,
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
          if (hasAnyData) ...[
            const SizedBox(height: UIConstants.paddingMedium),
            Row(
              children: [
                if (hasTotal)
                  Expanded(
                    child: _CostCard(
                      label: context.l10n.recipeCostTotal,
                      value: formatter.format(estimate.total),
                    ),
                  ),
                if (hasTotal && hasPerServing) const SizedBox(width: 12),
                if (hasPerServing)
                  Expanded(
                    child: _CostCard(
                      label: context.l10n.recipeCostPerServing,
                      value: formatter.format(estimate.perServing),
                    ),
                  ),
              ],
            ),
          ] else ...[
            const SizedBox(height: UIConstants.paddingMedium),
            Text(
              context.l10n.recipeCostNoPrices,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.recipeCostNoPricesSubtitle,
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
          if (actionableIngredients.isNotEmpty && onAddPrice != null) ...[
            const SizedBox(height: UIConstants.paddingMedium),
            _MissingPricesList(
              ingredients: actionableIngredients,
              onAddPrice: onAddPrice!,
              onIngredientTap: onIngredientTap,
              onIngredientLongPress: onIngredientLongPress,
            ),
          ],
          if (pricedIngredients.isNotEmpty) ...[
            const SizedBox(height: UIConstants.paddingMedium),
            if (actionableIngredients.isNotEmpty && onAddPrice != null) const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in pricedIngredients)
                  _PricedIngredientTile(
                    ingredient: entry.ingredient,
                    cost: entry.cost,
                    formatter: formatter,
                    onIngredientTap: onIngredientTap,
                    onIngredientLongPress: onIngredientLongPress,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: context.shapeSmall,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MissingPricesList extends StatelessWidget {
  const _MissingPricesList({
    required this.ingredients,
    required this.onAddPrice,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final List<RecipeIngredient> ingredients;
  final void Function(RecipeIngredient ingredient) onAddPrice;
  final void Function(RecipeIngredient ingredient)? onIngredientTap;
  final void Function(RecipeIngredient ingredient)? onIngredientLongPress;

  @override
  Widget build(BuildContext context) {
    final withFood = ingredients.where((i) => i.food != null).toList();
    if (withFood.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final ingredient in withFood)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            onTap: onIngredientTap != null ? () => onIngredientTap!(ingredient) : null,
            onLongPress: onIngredientLongPress != null ? () => onIngredientLongPress!(ingredient) : null,
            leading: StandardPicture(
              imageUrl: ingredient.food?.imageUrl,
              fallbackIcon: Icons.shopping_basket_outlined,
              size: 40,
              shape: PictureShape.circle,
              backgroundColor: Colors.transparent,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    ingredient.displayName,
                    style: context.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ingredient.displayAmount.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    '· ${ingredient.displayAmount}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            trailing: TextButton(
              onPressed: () => onAddPrice(ingredient),
              child: Text(context.l10n.recipeCostAddPrice),
            ),
          ),
      ],
    );
  }
}

class _PricedIngredientTile extends StatelessWidget {
  const _PricedIngredientTile({
    required this.ingredient,
    required this.cost,
    required this.formatter,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final RecipeIngredient ingredient;
  final RecipeIngredientCost cost;
  final NumberFormat formatter;
  final void Function(RecipeIngredient)? onIngredientTap;
  final void Function(RecipeIngredient)? onIngredientLongPress;

  @override
  Widget build(BuildContext context) {
    final price = cost.foodPrice;
    if (price == null) return const SizedBox.shrink();

    final amountStr = price.amount.formatAmount;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onIngredientTap != null ? () => onIngredientTap!(ingredient) : null,
      onLongPress: onIngredientLongPress != null ? () => onIngredientLongPress!(ingredient) : null,
      leading: Icon(Icons.check_circle_outline, color: context.colors.primary),
      title: Text(ingredient.displayName, style: context.textTheme.bodyMedium),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatter.format(cost.cost ?? price.price),
            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (price.unit != null)
            Text(
              context.l10n.foodPricePerAmountUnit(amountStr, price.unit!.name),
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
