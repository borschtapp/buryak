import 'package:json_annotation/json_annotation.dart';
import 'unit.dart';
import 'taxonomy.dart';

part 'food.g.dart';

@JsonSerializable()
class Food {
  final String id;
  final String slug;
  final String name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'default_unit_id')
  final String? defaultUnitId;
  final bool? pantry;

  // Preload fields
  final List<Taxonomy>? taxonomies;
  @JsonKey(name: 'default_unit')
  final Unit? defaultUnit;

  Food({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.imageUrl,
    this.defaultUnit,
    this.defaultUnitId,
    this.pantry,
    this.taxonomies,
  });

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
  Map<String, dynamic> toJson() => _$FoodToJson(this);
}
