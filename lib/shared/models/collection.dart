import 'package:json_annotation/json_annotation.dart';
import 'recipe.dart';

part 'collection.g.dart';

@JsonSerializable()
class Collection {
  final String id;
  @JsonKey(name: 'household_id')
  final String householdId;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String? description;

  // Preload fields, these are most likely empty
  @JsonKey(name: 'total_recipes')
  final int? totalRecipes;
  final List<Recipe>? recipes;

  Collection({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.name,
    this.description,
    this.recipes,
    this.totalRecipes,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionToJson(this);
}
