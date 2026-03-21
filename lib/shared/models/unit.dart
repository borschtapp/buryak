import 'package:json_annotation/json_annotation.dart';

import 'taxonomy.dart';

part 'unit.g.dart';

@JsonSerializable()
class Unit {
  final String id;
  final String slug;
  final String name;

  // Preload fields
  final List<Taxonomy>? taxonomies;

  Unit({
    required this.id,
    required this.slug,
    required this.name,
    this.taxonomies,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
