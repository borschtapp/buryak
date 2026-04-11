import 'package:freezed_annotation/freezed_annotation.dart';

import '../util/json_converters.dart';
import 'recipe.dart';

part 'meal_plan.freezed.dart';
part 'meal_plan.g.dart';

@JsonEnum(valueField: 'name')
enum MealType {
  @JsonValue('breakfast')
  breakfast,
  @JsonValue('lunch')
  lunch,
  @JsonValue('dinner')
  dinner,
  @JsonValue('snack')
  snack
  ;

  String toJsonValue() => _$MealTypeEnumMap[this]!;
}

@freezed
abstract class MealPlan with _$MealPlan {
  const factory MealPlan({
    required String id,
    @DateConverter() required DateTime date,
    @JsonKey(name: 'meal_type') required MealType mealType,
    @JsonKey(name: 'recipe_id') String? recipeId,
    int? servings,
    String? description,

    // Preload fields
    Recipe? recipe,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
}
