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
  const factory RecipeIngredientCost({
    @JsonKey(name: 'ingredient_id') required String ingredientId,
    double? cost,
    @JsonKey(name: 'food_price') FoodPrice? foodPrice,
    required String status,
  }) = _RecipeIngredientCost;

  factory RecipeIngredientCost.fromJson(Map<String, dynamic> json) => _$RecipeIngredientCostFromJson(json);
}

@freezed
abstract class RecipeCostEstimate with _$RecipeCostEstimate {
  const RecipeCostEstimate._();

  const factory RecipeCostEstimate({
    List<RecipeIngredientCost>? items,
    double? total,
    @JsonKey(name: 'per_serving') double? perServing,
  }) = _RecipeCostEstimate;

  bool get isComplete =>
      items == null ||
      !items!.any((i) => i.status == IngredientCostStatus.missingPrice || i.status == IngredientCostStatus.incompatibleUnit);

  int get missingCount =>
      items?.where((i) => i.status == IngredientCostStatus.missingPrice || i.status == IngredientCostStatus.incompatibleUnit).length ?? 0;

  factory RecipeCostEstimate.fromJson(Map<String, dynamic> json) => _$RecipeCostEstimateFromJson(json);
}
