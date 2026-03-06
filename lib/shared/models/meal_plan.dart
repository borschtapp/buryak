import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'meal_plan.g.dart';

@JsonSerializable()
class MealPlan {
  final String id;
  final String date;
  @JsonKey(name: 'meal_type')
  final String mealType;
  final String? note;
  final int? servings;
  @JsonKey(name: 'recipe_id')
  final String? recipeId;
  final Recipe? recipe;
  @JsonKey(name: 'household_id')
  final String? householdId;

  MealPlan({
    required this.id,
    required this.date,
    required this.mealType,
    this.note,
    this.servings,
    this.recipeId,
    this.recipe,
    this.householdId,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanToJson(this);
}
