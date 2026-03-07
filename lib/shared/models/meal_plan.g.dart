// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => MealPlan(
  id: json['id'] as String,
  date: json['date'] as String,
  mealType: json['meal_type'] as String,
  note: json['note'] as String?,
  servings: (json['servings'] as num?)?.toInt(),
  recipeId: json['recipe_id'] as String?,
  recipe: json['recipe'] == null
      ? null
      : Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
  householdId: json['household_id'] as String?,
);

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'meal_type': instance.mealType,
  'note': instance.note,
  'servings': instance.servings,
  'recipe_id': instance.recipeId,
  'recipe': instance.recipe,
  'household_id': instance.householdId,
};
