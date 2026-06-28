import 'package:freezed_annotation/freezed_annotation.dart';

import 'taxonomy.dart';
import 'unit.dart';

part 'food.freezed.dart';
part 'food.g.dart';

@freezed
abstract class Food with _$Food {
  const factory Food({
    required String id,
    required String slug,
    required String name,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'default_unit_id') String? defaultUnitId,
    bool? pantry,
    @JsonKey(name: 'canonical_food_id') String? canonicalFoodId,

    // Preload fields
    List<Taxonomy>? taxonomies,
    @JsonKey(name: 'default_unit') Unit? defaultUnit,
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
}
