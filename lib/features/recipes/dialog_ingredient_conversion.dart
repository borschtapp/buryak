import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/error_state.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/food_price.dart';
import '../../shared/models/food_unit_conversion.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/models/unit.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'dialog_food_conversion.dart';
import 'dialog_food_price.dart';

/// Fixes an `incompatible_unit` cost: the food has a [price], but in a unit the
/// ingredient's amount can't be converted to. Opens the conversion that links the
/// two units, or the price form when one conversion can't.
class IngredientConversionSheet extends ConsumerWidget {
  const IngredientConversionSheet({super.key, required this.ingredient, required this.price});

  /// Must have a [RecipeIngredient.food].
  final RecipeIngredient ingredient;

  /// The price the cost estimate tried.
  final FoodPrice price;

  static void show(BuildContext context, {required RecipeIngredient ingredient, required FoodPrice price}) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => IngredientConversionSheet(ingredient: ingredient, price: price),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ingredient.food!;
    final unitsAsync = ref.watch(allUnitsProvider);
    final conversionsAsync = ref.watch(foodConversionsProvider(food.id));
    final (units, conversions) = (unitsAsync.value, conversionsAsync.value);

    if (units == null || conversions == null) {
      final error = unitsAsync.error ?? conversionsAsync.error;
      return StandardBottomSheet(
        title: context.l10n.foodConversionTitle,
        child: error != null
            ? ErrorState(
                message: context.errorMessage(error),
                onRetry: () {
                  if (!unitsAsync.hasValue) ref.invalidate(allUnitsProvider);
                  ref.invalidate(foodConversionsProvider(food.id));
                },
              )
            : const Padding(
                padding: EdgeInsets.all(UIConstants.paddingLarge),
                child: Center(child: CircularProgressIndicator()),
              ),
      );
    }

    final unitsById = units.byId;
    final ingredientUnit = units.unitOrPiece(ingredient.unitId);
    final priceUnit = unitsById[price.unitId];
    final bridge = ingredientUnit != null && priceUnit != null ? bridgingConversion(ingredientUnit, priceUnit) : null;
    if (bridge == null) return FoodPriceBottomSheet(food: food, ingredient: ingredient);

    return FoodConversionBottomSheet(
      food: food,
      unitId: bridge.source.id,
      unitName: bridge.source.name,
      // A food has at most one conversion per source unit, so an existing one is retargeted.
      existing: conversions.fromUnit(bridge.source.id),
      targetUnitId: bridge.target.id,
    );
  }
}
