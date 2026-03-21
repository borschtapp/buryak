import 'package:json_annotation/json_annotation.dart';

import 'recipe.dart';

part 'collection.g.dart';

@JsonSerializable()
class Collection {
  final String id;
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
    required this.userId,
    required this.name,
    this.description,
    this.recipes,
    this.totalRecipes,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  Collection copyWith({
    String? name,
    String? description,
    List<Recipe>? recipes,
    int? totalRecipes,
  }) {
    return Collection(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      recipes: recipes ?? this.recipes,
      totalRecipes: totalRecipes ?? this.totalRecipes,
    );
  }
}
