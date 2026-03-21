import 'package:json_annotation/json_annotation.dart';

import 'feed.dart';
import 'recipe.dart';

part 'publisher.g.dart';

@JsonSerializable()
class Publisher {
  final String id;
  final String name;
  final String? description;
  final String url;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  // Preload fields
  @JsonKey(name: 'total_recipes')
  final int? totalRecipes;
  final List<Feed>? feeds;
  final List<Recipe>? recipes;

  Publisher({
    required this.id,
    required this.name,
    this.description,
    required this.url,
    this.imageUrl,
    this.totalRecipes,
    this.feeds,
    this.recipes,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);

  Map<String, dynamic> toJson() => _$PublisherToJson(this);
}
