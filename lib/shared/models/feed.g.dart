// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) => Feed(
  id: json['id'] as String,
  url: json['url'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  websiteUrl: json['website_url'] as String?,
  active: json['active'] as bool?,
  lastFetchedAt: json['last_fetched_at'] == null ? null : DateTime.parse(json['last_fetched_at'] as String),
  errorCount: (json['error_count'] as num?)?.toInt(),
  created: DateTime.parse(json['created'] as String),
  updated: DateTime.parse(json['updated'] as String),
  recipes: (json['recipes'] as List<dynamic>?)?.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList(),
  users: (json['users'] as List<dynamic>?)?.map((e) => User.fromJson(e as Map<String, dynamic>)).toList(),
);

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'name': instance.name,
  'description': instance.description,
  'website_url': instance.websiteUrl,
  'active': instance.active,
  'last_fetched_at': instance.lastFetchedAt?.toIso8601String(),
  'error_count': instance.errorCount,
  'created': instance.created.toIso8601String(),
  'updated': instance.updated.toIso8601String(),
  'recipes': instance.recipes,
  'users': instance.users,
};
