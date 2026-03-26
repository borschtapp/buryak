import 'package:json_annotation/json_annotation.dart';

import 'recipe.dart';

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

@JsonSerializable()
class MealPlan {
  final String id;
  @_DateConverter()
  final DateTime date;
  @JsonKey(name: 'meal_type')
  final MealType mealType;
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

  MealPlan copyWith({
    DateTime? date,
    MealType? mealType,
    String? description,
    int? servings,
    String? recipeId,
    Recipe? recipe,
  }) {
    return MealPlan(
      id: id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      description: description ?? this.description,
      servings: servings ?? this.servings,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe ?? this.recipe,
    );
  }
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
