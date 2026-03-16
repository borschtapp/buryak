// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxonomy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Taxonomy _$TaxonomyFromJson(Map<String, dynamic> json) => Taxonomy(
  id: json['id'] as String,
  slug: json['slug'] as String?,
  type: json['type'] as String?,
  label: json['label'] as String?,
  parentId: json['parent_id'] as String?,
  parent: json['parent'] == null
      ? null
      : Taxonomy.fromJson(json['parent'] as Map<String, dynamic>),
  canonicalId: json['canonical_id'] as String?,
  canonical: json['canonical'] == null
      ? null
      : Taxonomy.fromJson(json['canonical'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaxonomyToJson(Taxonomy instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'type': instance.type,
  'label': instance.label,
  'parent_id': instance.parentId,
  'parent': instance.parent,
  'canonical_id': instance.canonicalId,
  'canonical': instance.canonical,
};
