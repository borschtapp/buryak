import 'package:json_annotation/json_annotation.dart';
import 'food.dart';
import 'unit.dart';

part 'recipe_ingredient.g.dart';

@JsonSerializable()
class RecipeIngredient {
  final String id;
  final double? amount;
  final String? kind;
  final String? note;
  @JsonKey(name: 'raw_text')
  final String? rawText;
  final Food? food;
  @JsonKey(name: 'food_id')
  final String? foodId;
  final Unit? unit;
  @JsonKey(name: 'unit_id')
  final String? unitId;

  RecipeIngredient({
    required this.id,
    this.amount,
    this.kind,
    this.note,
    this.rawText,
    this.food,
    this.foodId,
    this.unit,
    this.unitId,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) => _$RecipeIngredientFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);
}
