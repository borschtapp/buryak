import 'package:json_annotation/json_annotation.dart';
import 'image.dart';
import 'unit.dart';
import 'taxonomy.dart';

part 'food.g.dart';

@JsonSerializable()
class Food {
  final String id;
  final String slug;
  final String name;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'default_unit_id')
  final String? defaultUnitId;

  // Preload fields
  final List<Image>? images;
  final List<Taxonomy>? taxonomies;
  @JsonKey(name: 'default_unit')
  final Unit? defaultUnit;

  Food({
    required this.id,
    required this.slug,
    required this.name,
    this.imageUrl,
    this.images,
    this.defaultUnit,
    this.defaultUnitId,
    this.taxonomies,
  });

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
  Map<String, dynamic> toJson() => _$FoodToJson(this);
}
