// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecipeIngredient _$RecipeIngredientFromJson(Map<String, dynamic> json) =>
    RecipeIngredient(
      id: json['id'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      kind: json['kind'] as String?,
      note: json['note'] as String?,
      rawText: json['raw_text'] as String?,
      food: json['food'] == null
          ? null
          : Food.fromJson(json['food'] as Map<String, dynamic>),
      foodId: json['food_id'] as String?,
      unit: json['unit'] == null
          ? null
          : Unit.fromJson(json['unit'] as Map<String, dynamic>),
      unitId: json['unit_id'] as String?,
    );

Map<String, dynamic> _$RecipeIngredientToJson(RecipeIngredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'kind': instance.kind,
      'note': instance.note,
      'raw_text': instance.rawText,
      'food': instance.food,
      'food_id': instance.foodId,
      'unit': instance.unit,
      'unit_id': instance.unitId,
    };
