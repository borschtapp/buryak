import 'package:freezed_annotation/freezed_annotation.dart';

part 'taxonomy.freezed.dart';

part 'taxonomy.g.dart';

@freezed
abstract class Taxonomy with _$Taxonomy {
  const factory Taxonomy({
    required String id,
    String? slug,
    String? type,
    String? label,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'canonical_id') String? canonicalId,

    // Preload fields
    Taxonomy? parent,
    Taxonomy? canonical,
  }) = _Taxonomy;

  factory Taxonomy.fromJson(Map<String, dynamic> json) => _$TaxonomyFromJson(json);
}
