// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
  name: json['name'] as String?,
  description: json['description'] as String?,
  embedUrl: json['embed_url'] as String?,
  contentUrl: json['content_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'embed_url': instance.embedUrl,
  'content_url': instance.contentUrl,
  'thumbnail_url': instance.thumbnailUrl,
};
