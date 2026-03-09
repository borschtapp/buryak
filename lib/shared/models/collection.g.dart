// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collection _$CollectionFromJson(Map<String, dynamic> json) => Collection(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  householdId: json['household_id'] as String?,
  recipes: (json['recipes'] as List<dynamic>?)?.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList(),
  totalRecipes: (json['total_recipes'] as num?)?.toInt(),
);

Map<String, dynamic> _$CollectionToJson(Collection instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'household_id': instance.householdId,
  'recipes': instance.recipes,
  'total_recipes': instance.totalRecipes,
};
