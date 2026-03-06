// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
  name: json['name'] as String?,
  description: json['description'] as String?,
  url: json['url'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'url': instance.url,
  'image': instance.image,
};
