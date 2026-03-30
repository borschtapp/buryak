import 'package:freezed_annotation/freezed_annotation.dart';

import 'recipe.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

@freezed
abstract class Collection with _$Collection {
  const factory Collection({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,

    // Preload fields, these are most likely empty
    @JsonKey(name: 'total_recipes') int? totalRecipes,
    List<Recipe>? recipes,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);
}
