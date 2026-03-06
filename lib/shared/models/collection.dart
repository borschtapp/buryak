import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'collection.g.dart';

@JsonSerializable()
class Collection {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'household_id')
  final String? householdId;
  final List<Recipe>? recipes;

  Collection({
    required this.id,
    required this.name,
    this.description,
    this.householdId,
    this.recipes,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionToJson(this);
}
