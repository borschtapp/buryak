import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/error_state.dart';
import '../../shared/components/standard_bottom_sheet.dart';
import '../../shared/models/recipe_ingredient.dart';
import '../../shared/models/unit.dart';
import '../../shared/providers/recipe_price.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'dialog_food_conversion.dart';
import 'dialog_food_price.dart';

/// Fixes an `incompatible_unit` cost: the food has a price, but in a unit the
/// ingredient's amount can't be converted to. Opens the conversion that links the
/// two units, or the price form when one conversion can't.
///
/// The cost estimate doesn't say which price it tried, so the food's latest price
/// (the one the server uses) is loaded first.
class IngredientConversionSheet extends HookConsumerWidget {
  const IngredientConversionSheet({super.key, required this.ingredient});

  /// Must have a [RecipeIngredient.food].
  final RecipeIngredient ingredient;

  static void show(BuildContext context, {required RecipeIngredient ingredient}) {
    showAppBottomSheet<void>(
      context: context,
      builder: (_) => IngredientConversionSheet(ingredient: ingredient),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final food = ingredient.food!;
    final unitsAsync = ref.watch(allUnitsProvider);
    final pricesAsync = ref.watch(foodPricesProvider(food.id));
    final conversionsAsync = ref.watch(foodConversionsProvider(food.id));
    final (units, prices, conversions) = (unitsAsync.value, pricesAsync.value, conversionsAsync.value);

    // Read once loaded: a price recorded in the fallback form must not swap the sheet under it.
    final priceUnitId = useMemoized(() => prices?.data.firstOrNull?.unitId, [prices == null]);

    if (units == null || prices == null || conversions == null) {
      final error = <AsyncValue<Object?>>[unitsAsync, pricesAsync, conversionsAsync].where((a) => a.hasError).firstOrNull?.error;
      return StandardBottomSheet(
        title: context.l10n.foodConversionTitle,
        child: error != null
            ? ErrorState(
                message: context.errorMessage(error),
                onRetry: () {
                  if (!unitsAsync.hasValue) ref.invalidate(allUnitsProvider);
                  ref
                    ..invalidate(foodPricesProvider(food.id))
                    ..invalidate(foodConversionsProvider(food.id));
                },
              )
            : const Padding(
                padding: EdgeInsets.all(UIConstants.paddingLarge),
                child: Center(child: CircularProgressIndicator()),
              ),
      );
    }

    final unitsById = units.byId;
    final ingredientUnit = ingredient.unitId != null ? unitsById[ingredient.unitId] : units.piece;
    final priceUnit = unitsById[priceUnitId];
    final bridge = ingredientUnit != null && priceUnit != null ? bridgingConversion(ingredientUnit, priceUnit) : null;
    if (bridge == null) return FoodPriceBottomSheet(food: food, ingredient: ingredient);

    return FoodConversionBottomSheet(
      food: food,
      unitId: bridge.source.id,
      unitName: bridge.source.name,
      prices: prices.data,
      // A food has at most one conversion per source unit, so an existing one is retargeted.
      existing: conversions.where((c) => c.unitId == bridge.source.id).firstOrNull,
      targetUnitId: bridge.target.id,
    );
  }
}
