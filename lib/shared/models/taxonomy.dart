import 'package:json_annotation/json_annotation.dart';

part 'taxonomy.g.dart';

@JsonSerializable()
class Taxonomy {
  final String id;
  final String? slug;
  final String? type;
  final String? label;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  final Taxonomy? parent;
  @JsonKey(name: 'canonical_id')
  final String? canonicalId;
  final Taxonomy? canonical;

  Taxonomy({
    required this.id,
    this.slug,
    this.type,
    this.label,
    this.parentId,
    this.parent,
    this.canonicalId,
    this.canonical,
  });

  factory Taxonomy.fromJson(Map<String, dynamic> json) => _$TaxonomyFromJson(json);
  Map<String, dynamic> toJson() => _$TaxonomyToJson(this);
}
