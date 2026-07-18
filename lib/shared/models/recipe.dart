import 'package:freezed_annotation/freezed_annotation.dart';

import 'author.dart';
import 'collection.dart';
import 'equipment.dart';
import 'publisher.dart';
import 'rating.dart';
import 'recipe_ingredient.dart';
import 'recipe_instruction.dart';
import 'recipe_nutrition.dart';
import 'recipe_saved_user.dart';
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
    String? imageUrl,
    String? language,
    Author? author,
    String? authorId,
    String? text,
    int? prepTime,
    int? cookTime,
    int? totalTime,
    String? difficulty,
    String? method,
    int? yield,
    List<Equipment>? equipment,
    RecipeNutrition? nutrition,
    Rating? rating,
    Video? video,
    DateTime? published,
    String? feedId,
    List<RecipeSavedUser>? savedBy,
    String? userId,
    String? sourceUrl,

    // Preload fields
    Publisher? publisher,
    String? publisherId,
    List<Collection>? collections,
    List<RecipeIngredient>? ingredients,
    List<RecipeInstruction>? instructions,
    List<Taxonomy>? taxonomies,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}

extension RecipeCooking on Recipe {
  bool get hasCookableInstructions => instructions?.isNotEmpty ?? false;
  bool get hasFoodIngredients => (ingredients ?? []).any((i) => i.foodId != null);
}
