import 'package:json_annotation/json_annotation.dart';

import 'food.dart';
import 'unit.dart';

part 'recipe_ingredient.g.dart';

@JsonSerializable()
class RecipeIngredient {
  final String id;
  final double? amount;
  @JsonKey(name: 'max_amount')
  final double? maxAmount;
  final String? name;
  final String? category;
  final String? description;
  @JsonKey(name: 'raw_text')
  final String? rawText;
  @JsonKey(name: 'food_id')
  final String? foodId;
  @JsonKey(name: 'unit_id')
  final String? unitId;

  // Preload fields
  final Food? food;
  final Unit? unit;

  RecipeIngredient({
    required this.id,
    this.amount,
    this.maxAmount,
    this.name,
    this.category,
    this.description,
    this.rawText,
    this.food,
    this.foodId,
    this.unit,
    this.unitId,
  });

  String get displayName => name ?? food?.name ?? rawText ?? description ?? 'Unknown ingredient';

  String get displayAmount {
    final hasMax = maxAmount != null && maxAmount != 0;
    return [
      if (amount != null && amount != 0) hasMax ? '$amount-$maxAmount' : amount.toString(),
      if (unit?.name.trim().isNotEmpty == true) unit!.name,
    ].where((s) => s.trim().isNotEmpty).join(' ');
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}
