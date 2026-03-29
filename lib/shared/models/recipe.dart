import 'package:freezed_annotation/freezed_annotation.dart';

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

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    String? url,
    required String name,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? language,
    Author? author,
    @JsonKey(name: 'author_id') String? authorId,
    String? text,
    @JsonKey(name: 'prep_time') int? prepTime,
    @JsonKey(name: 'cook_time') int? cookTime,
    @JsonKey(name: 'total_time') int? totalTime,
    String? difficulty,
    String? method,
    int? yield,
    List<Equipment>? equipment,
    RecipeNutrition? nutrition,
    Rating? rating,
    Video? video,
    DateTime? published,
    @JsonKey(name: 'feed_id') String? feedId,
    @JsonKey(name: 'is_saved') bool? isSaved,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'source_url') String? sourceUrl,

    // Preload fields
    Publisher? publisher,
    @JsonKey(name: 'publisher_id') String? publisherId,
    List<Collection>? collections,
    List<RecipeIngredient>? ingredients,
    List<RecipeInstruction>? instructions,
    List<Taxonomy>? taxonomies,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
