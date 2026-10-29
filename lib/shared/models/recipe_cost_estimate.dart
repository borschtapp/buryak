import 'package:freezed_annotation/freezed_annotation.dart';

import 'food_price.dart';

part 'recipe_cost_estimate.freezed.dart';
part 'recipe_cost_estimate.g.dart';

/// Status values returned by the cost-estimate API for each ingredient.
abstract final class IngredientCostStatus {
  static const missingPrice = 'missing_price';
  static const incompatibleUnit = 'incompatible_unit';
  static const calculated = 'calculated';
}

@freezed
abstract class RecipeIngredientCost with _$RecipeIngredientCost {
  const RecipeIngredientCost._();

  const factory RecipeIngredientCost({
    required String ingredientId,
    double? cost,
    FoodPrice? foodPrice,
    required String status,
  }) = _RecipeIngredientCost;

  /// Left out of the total until a price, or a conversion to the price's unit, is added.
  bool get isUnpriced => status == IngredientCostStatus.missingPrice || status == IngredientCostStatus.incompatibleUnit;

  factory RecipeIngredientCost.fromJson(Map<String, dynamic> json) => _$RecipeIngredientCostFromJson(json);
}

@freezed
abstract class RecipeCostEstimate with _$RecipeCostEstimate {
  const RecipeCostEstimate._();

  const factory RecipeCostEstimate({
    List<RecipeIngredientCost>? items,
    double? total,
    double? perServing,
  }) = _RecipeCostEstimate;

  bool get isComplete => items == null || !items!.any((i) => i.isUnpriced);

  int get missingCount => items?.where((i) => i.isUnpriced).length ?? 0;

  factory RecipeCostEstimate.fromJson(Map<String, dynamic> json) => _$RecipeCostEstimateFromJson(json);
}
