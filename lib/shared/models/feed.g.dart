// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) => Feed(
  id: json['id'] as String,
  url: json['url'] as String,
  name: json['name'] as String?,
  active: json['active'] as bool?,
  lastSyncAt: json['last_sync_at'] as String?,
  lastSyncSuccess: json['last_sync_success'] as bool?,
  errorCount: (json['error_count'] as num?)?.toInt(),
  updated: json['updated'] as String?,
  created: json['created'] as String?,
  publisher: json['publisher'] == null
      ? null
      : Publisher.fromJson(json['publisher'] as Map<String, dynamic>),
  recipes: (json['recipes'] as List<dynamic>?)
      ?.map((e) => Recipe.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalRecipes: (json['total_recipes'] as num?)?.toInt(),
);

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'name': instance.name,
  'active': instance.active,
  'last_sync_at': instance.lastSyncAt,
  'last_sync_success': instance.lastSyncSuccess,
  'error_count': instance.errorCount,
  'updated': instance.updated,
  'created': instance.created,
  'publisher': instance.publisher,
  'recipes': instance.recipes,
  'total_recipes': instance.totalRecipes,
};
