import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/food_price.dart';
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
    this.onAddConversion,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final String recipeId;
  final List<RecipeIngredient> ingredients;
  final void Function(RecipeIngredient ingredient)? onAddPrice;

  /// For an ingredient whose food has a [price] in a unit its amount can't be converted to.
  final void Function(RecipeIngredient ingredient, FoodPrice price)? onAddConversion;

  /// For an ingredient without a food; one with a food opens [onAddPrice] when set.
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
          onAddConversion: onAddConversion,
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
    this.onAddConversion,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final RecipeCostEstimate estimate;
  final List<RecipeIngredient> ingredients;
  final String? currency;
  final void Function(RecipeIngredient ingredient)? onAddPrice;
  final void Function(RecipeIngredient ingredient, FoodPrice price)? onAddConversion;
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

    final actionableIngredients = <({RecipeIngredient ingredient, RecipeIngredientCost cost})>[];
    final pricedIngredients = <({RecipeIngredient ingredient, RecipeIngredientCost cost})>[];

    for (final ingredient in ingredients) {
      final cost = costByIngredientId[ingredient.id];
      if (cost == null) continue;
      if (cost.isUnpriced) {
        actionableIngredients.add((ingredient: ingredient, cost: cost));
      } else if (cost.status == IngredientCostStatus.calculated) {
        pricedIngredients.add((ingredient: ingredient, cost: cost));
      }
      // pantry items intentionally omitted from both lists
    }

    // An ingredient with a food opens its price; one without opens the ingredient.
    final (addPrice, tap) = (onAddPrice, onIngredientTap);
    final onTap = addPrice == null ? tap : (RecipeIngredient i) => i.food != null ? addPrice(i) : tap?.call(i);

    final totalCount = actionableIngredients.length + pricedIngredients.length;
    final pricedCount = pricedIngredients.length;

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
            if (totalCount > 0) ...[
              const SizedBox(height: UIConstants.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: pricedCount / totalCount,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: context.colors.surfaceContainerHighest,
                      color: pricedCount == totalCount ? context.colors.primary : context.colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: UIConstants.paddingMedium),
                  Text(
                    context.l10n.recipeCostProgress(pricedCount, totalCount),
                    style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
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
            const SizedBox(height: UIConstants.paddingLarge),
            _SectionHeader(
              title: context.l10n.recipeCostSectionMissing,
              count: actionableIngredients.length,
              containerColor: context.colors.errorContainer,
              onContainerColor: context.colors.onErrorContainer,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            _MissingPricesList(
              ingredients: actionableIngredients,
              onAddPrice: onAddPrice!,
              onAddConversion: onAddConversion,
              onIngredientTap: onTap,
              onIngredientLongPress: onIngredientLongPress,
            ),
          ],
          if (pricedIngredients.isNotEmpty) ...[
            const SizedBox(height: UIConstants.paddingLarge),
            _SectionHeader(
              title: context.l10n.recipeCostSectionPriced,
              count: pricedIngredients.length,
              containerColor: context.colors.primaryContainer,
              onContainerColor: context.colors.onPrimaryContainer,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in pricedIngredients)
                  _PricedIngredientTile(
                    ingredient: entry.ingredient,
                    cost: entry.cost,
                    formatter: formatter,
                    onIngredientTap: onTap,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.containerColor,
    required this.onContainerColor,
  });

  final String title;
  final int count;
  final Color containerColor;
  final Color onContainerColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: UIConstants.paddingSmall),
        Badge.count(count: count, backgroundColor: containerColor, textColor: onContainerColor),
      ],
    );
  }
}

class _MissingPricesList extends StatelessWidget {
  const _MissingPricesList({
    required this.ingredients,
    required this.onAddPrice,
    this.onAddConversion,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  final List<({RecipeIngredient ingredient, RecipeIngredientCost cost})> ingredients;
  final void Function(RecipeIngredient ingredient) onAddPrice;
  final void Function(RecipeIngredient ingredient, FoodPrice price)? onAddConversion;
  final void Function(RecipeIngredient ingredient)? onIngredientTap;
  final void Function(RecipeIngredient ingredient)? onIngredientLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (:ingredient, :cost) in ingredients)
          _IngredientTile(
            ingredient: ingredient,
            onTap: onIngredientTap,
            onLongPress: onIngredientLongPress,
            // Free-text ingredients can't be priced until they're linked to a food.
            trailing: ingredient.food == null ? null : _addButton(context, ingredient, cost),
          ),
      ],
    );
  }

  /// A conversion when the food is priced in a unit the amount can't be converted to, else a price.
  Widget _addButton(BuildContext context, RecipeIngredient ingredient, RecipeIngredientCost cost) {
    final (addConversion, price) = (onAddConversion, cost.foodPrice);
    if (cost.status == IngredientCostStatus.incompatibleUnit && addConversion != null && price != null) {
      return TextButton(onPressed: () => addConversion(ingredient, price), child: Text(context.l10n.recipeCostAddConversion));
    }
    return TextButton(onPressed: () => onAddPrice(ingredient), child: Text(context.l10n.recipeCostAddPrice));
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

    // The title shows the recipe's amount; this shows the price the cost comes from.
    final priceText = formatter.format(price.price);
    final basis = switch (price.unit?.name) {
      null => null,
      final unit when price.amount == 1 => context.l10n.recipeCostPriceBasis(priceText, unit),
      final unit => context.l10n.recipeCostPriceBasisAmount(priceText, price.amount.formatAmount, unit),
    };

    return _IngredientTile(
      ingredient: ingredient,
      priced: true,
      onTap: onIngredientTap,
      onLongPress: onIngredientLongPress,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatter.format(cost.cost ?? price.price),
            style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (basis != null)
            Text(
              basis,
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

/// An ingredient row: its picture, with a check once [priced], and its name and amount.
class _IngredientTile extends StatelessWidget {
  const _IngredientTile({
    required this.ingredient,
    this.priced = false,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  final RecipeIngredient ingredient;
  final bool priced;
  final void Function(RecipeIngredient)? onTap;
  final void Function(RecipeIngredient)? onLongPress;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final (tap, longPress) = (onTap, onLongPress);
    final picture = StandardPicture(
      imageUrl: ingredient.food?.imageUrl,
      fallbackIcon: Icons.shopping_basket_outlined,
      size: 40,
      shape: PictureShape.circle,
      backgroundColor: Colors.transparent,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: tap != null ? () => tap(ingredient) : null,
      onLongPress: longPress != null ? () => longPress(ingredient) : null,
      leading: !priced
          ? picture
          : Stack(
              clipBehavior: Clip.none,
              children: [
                picture,
                PositionedDirectional(
                  end: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 10, color: context.colors.onPrimary),
                  ),
                ),
              ],
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
      trailing: trailing,
    );
  }
}
