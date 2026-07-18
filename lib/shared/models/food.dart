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
    String? imageUrl,
    String? defaultUnitId,
    bool? pantry,
    String? canonicalFoodId,

    // Preload fields
    List<Taxonomy>? taxonomies,
    Unit? defaultUnit,
  }) = _Food;

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
}
