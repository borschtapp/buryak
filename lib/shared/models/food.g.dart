// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Food _$FoodFromJson(Map<String, dynamic> json) => Food(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String?,
  imageUrl: json['image_url'] as String?,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
      .toList(),
  defaultUnit: json['default_unit'] == null
      ? null
      : Unit.fromJson(json['default_unit'] as Map<String, dynamic>),
  defaultUnitId: json['default_unit_id'] as String?,
  taxonomies: (json['taxonomies'] as List<dynamic>?)
      ?.map((e) => Taxonomy.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FoodToJson(Food instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'image_url': instance.imageUrl,
  'images': instance.images,
  'default_unit': instance.defaultUnit,
  'default_unit_id': instance.defaultUnitId,
  'taxonomies': instance.taxonomies,
};
