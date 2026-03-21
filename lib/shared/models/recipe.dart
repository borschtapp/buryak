import 'package:json_annotation/json_annotation.dart';

import 'author.dart';
import 'collection.dart';
import 'equipment.dart';
import 'publisher.dart';
import 'rating.dart';
import 'recipe_ingredient.dart';
import 'recipe_instruction.dart';
import 'recipe_nutrition.dart';
import 'taxonomy.dart';
import 'video.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String? url;
  final String name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? language;
  final Author? author;
  @JsonKey(name: 'author_id')
  final String? authorId;
  final String? text;
  @JsonKey(name: 'prep_time')
  final int? prepTime;
  @JsonKey(name: 'cook_time')
  final int? cookTime;
  @JsonKey(name: 'total_time')
  final int? totalTime;
  final String? difficulty;
  final String? method;
  final int? yield;
  final List<Equipment>? equipment;
  final RecipeNutrition? nutrition;
  final Rating? rating;
  final Video? video;
  final DateTime? published;
  @JsonKey(name: 'feed_id')
  final String? feedId;
  @JsonKey(name: 'is_saved')
  final bool? isSaved;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'source_url')
  final String? sourceUrl;

  // Preload fields
  final Publisher? publisher;
  final List<Collection>? collections;
  final List<RecipeIngredient>? ingredients;
  final List<RecipeInstruction>? instructions;
  final List<Taxonomy>? taxonomies;
  @JsonKey(name: 'publisher_id')
  final String? publisherId;

  Recipe({
    required this.id,
    this.url,
    required this.name,
    this.description,
    this.imageUrl,
    this.language,
    this.publisher,
    this.publisherId,
    this.author,
    this.authorId,
    this.text,
    this.prepTime,
    this.cookTime,
    this.totalTime,
    this.difficulty,
    this.method,
    this.taxonomies,
    this.yield,
    this.equipment,
    this.ingredients,
    this.instructions,
    this.nutrition,
    this.rating,
    this.video,
    this.published,
    this.feedId,
    this.isSaved,
    this.userId,
    this.sourceUrl,
    this.collections,
  });

  String? get primaryImageUrl {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) return imageUrl;
    return null;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
