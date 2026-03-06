import 'package:json_annotation/json_annotation.dart';
import 'unit.dart';
import 'taxonomy.dart';

part 'food.g.dart';

@JsonSerializable()
class Food {
  final String id;
  final String name;
  final String? icon;
  @JsonKey(name: 'default_unit')
  final Unit? defaultUnit;
  @JsonKey(name: 'default_unit_id')
  final String? defaultUnitId;
  final List<Taxonomy>? taxonomies;

  Food({
    required this.id,
    required this.name,
    this.icon,
    this.defaultUnit,
    this.defaultUnitId,
    this.taxonomies,
  });

  factory Food.fromJson(Map<String, dynamic> json) => _$FoodFromJson(json);
  Map<String, dynamic> toJson() => _$FoodToJson(this);
}
