import 'package:freezed_annotation/freezed_annotation.dart';

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
    @_DateConverter() required DateTime date,
    @JsonKey(name: 'meal_type') required MealType mealType,
    @JsonKey(name: 'recipe_id') String? recipeId,
    int? servings,
    String? description,

    // Preload fields
    Recipe? recipe,
  }) = _MealPlan;

  factory MealPlan.fromJson(Map<String, dynamic> json) => _$MealPlanFromJson(json);
}

class _DateConverter implements JsonConverter<DateTime, String> {
  const _DateConverter();

  @override
  DateTime fromJson(String json) {
    // If it's a date-only string (e.g. "2024-01-01"), treat it as UTC midnight.
    if (json.length == 10 && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(json)) {
      return DateTime.parse('${json}T00:00:00Z');
    }
    return DateTime.parse(json);
  }

  @override
  String toJson(DateTime json) => json.toIso8601String().split('T')[0];
}
