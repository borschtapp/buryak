import 'package:json_annotation/json_annotation.dart';
import 'author.dart';
import 'publisher.dart';
import 'rating.dart';
import 'recipe_image.dart';
import 'recipe_ingredient.dart';
import 'recipe_instruction.dart';
import 'nutrition.dart';
import 'taxonomy.dart';
import 'video.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  final String id;
  final String? url;
  final String name;
  final String? description;
  final List<RecipeImage>? images;
  final String? language;
  final Publisher? publisher;
  final Author? author;
  final String? text;
  @JsonKey(name: 'prep_time')
  final int? prepTime;
  @JsonKey(name: 'cook_time')
  final int? cookTime;
  @JsonKey(name: 'total_time')
  final int? totalTime;
  final String? difficulty;
  final String? method;
  final List<Taxonomy>? taxonomies;
  final int? yield;
  final List<String>? equipment;
  final List<RecipeIngredient>? ingredients;
  final List<RecipeInstruction>? instructions;
  final Nutrition? nutrition;
  final Rating? rating;
  final Video? video;
  final DateTime? published;
  final DateTime updated;
  final DateTime created;
  @JsonKey(name: 'feed_id')
  final String? feedId;
  @JsonKey(name: 'is_based_on')
  final String? isBasedOn;

  Recipe({
    required this.id,
    this.url,
    required this.name,
    this.description,
    this.images,
    this.language,
    this.publisher,
    this.author,
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
    required this.updated,
    required this.created,
    this.feedId,
    this.isBasedOn,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
