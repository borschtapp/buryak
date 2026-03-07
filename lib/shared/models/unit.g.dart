// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
  id: json['id'] as String,
  name: json['name'] as String,
  taxonomies: (json['taxonomies'] as List<dynamic>?)
      ?.map((e) => Taxonomy.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'taxonomies': instance.taxonomies,
};
