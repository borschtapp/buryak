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
  image: json['image'] as String?,
);

Map<String, dynamic> _$PublisherToJson(Publisher instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'description': instance.description,
  'image': instance.image,
};
