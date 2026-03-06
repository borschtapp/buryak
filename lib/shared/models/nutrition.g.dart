// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nutrition _$NutritionFromJson(Map<String, dynamic> json) => Nutrition(
  calories: (json['calories'] as num?)?.toDouble(),
  carbs: (json['carbs'] as num?)?.toDouble(),
  carbsFiber: (json['carbs_fiber'] as num?)?.toDouble(),
  carbsSugar: (json['carbs_sugar'] as num?)?.toDouble(),
  cholesterol: (json['cholesterol'] as num?)?.toDouble(),
  fat: (json['fat'] as num?)?.toDouble(),
  fatSaturated: (json['fat_saturated'] as num?)?.toDouble(),
  fatTrans: (json['fat_trans'] as num?)?.toDouble(),
  protein: (json['protein'] as num?)?.toDouble(),
  servingSize: json['serving_size'] as String?,
  sodium: (json['sodium'] as num?)?.toDouble(),
);

Map<String, dynamic> _$NutritionToJson(Nutrition instance) => <String, dynamic>{
  'calories': instance.calories,
  'carbs': instance.carbs,
  'carbs_fiber': instance.carbsFiber,
  'carbs_sugar': instance.carbsSugar,
  'cholesterol': instance.cholesterol,
  'fat': instance.fat,
  'fat_saturated': instance.fatSaturated,
  'fat_trans': instance.fatTrans,
  'protein': instance.protein,
  'serving_size': instance.servingSize,
  'sodium': instance.sodium,
};
