import 'package:json_annotation/json_annotation.dart';
import 'author.dart';
import 'feed.dart';
import 'image.dart';
import 'publisher.dart';
import 'rating.dart';
import 'recipe_ingredient.dart';
import 'recipe_instruction.dart';
import 'nutrition.dart';
import 'taxonomy.dart';
import 'video.dart';
import 'collection.dart';

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
  final List<String>? equipment;
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
  @JsonKey(name: 'is_saved')
  final bool? isSaved;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'household_id')
  final String? householdId;

  // Preload fields
  final Feed? feed;
  final Publisher? publisher;
  final List<Image>? images;
  final List<Collection>? collections;
  final List<RecipeIngredient>? ingredients;
  final List<RecipeInstruction>? instructions;
  final List<Taxonomy>? taxonomies;

  Recipe({
    required this.id,
    this.url,
    required this.name,
    this.description,
    this.imageUrl,
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
    this.feed,
    this.isBasedOn,
    this.isSaved,
    this.parentId,
    this.userId,
    this.householdId,
    this.collections,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}
