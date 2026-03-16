// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Publisher _$PublisherFromJson(Map<String, dynamic> json) => Publisher(
  id: json['id'] as String,
  name: json['name'] as String,
  url: json['url'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => Image.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalRecipes: (json['total_recipes'] as num?)?.toInt(),
);

Map<String, dynamic> _$PublisherToJson(Publisher instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'images': instance.images,
  'total_recipes': instance.totalRecipes,
};
