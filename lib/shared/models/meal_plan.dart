import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'meal_plan.g.dart';

@JsonSerializable()
class MealPlan {
  final String id;
  final String date;
  @JsonKey(name: 'meal_type')
  final String mealType;
  @JsonKey(name: 'recipe_id')
  final String? recipeId;
  final int? servings;
  final String? description;

  // Preload fields
  final Recipe? recipe;

  MealPlan({
    required this.id,
    required this.date,
    required this.mealType,
    this.servings,
    this.description,
    this.recipeId,
    this.recipe,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanToJson(this);
}
