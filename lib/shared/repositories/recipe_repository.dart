import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_instruction.dart';
import '../models/paginated_list.dart';

part 'recipe_repository.g.dart';

@Riverpod(keepAlive: true)
RecipeRepository recipeRepository(Ref ref) => RecipeRepository(ref: ref);

class RecipeRepository extends Repository {
  const RecipeRepository({required super.ref, super.client}) : super(module: '/api/v1/recipes');

  Future<PaginatedList<Recipe>> findAll({
    String? preload,
    int? limit,
    String? q,
    String? taxonomies,
    String? cuisine,
    String? sort,
    String? order,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'q': ?q,
        'taxonomies': ?taxonomies,
        'cuisine': ?cuisine,
        'preload': ?preload,
        'sort': ?sort,
        'order': ?order,
        'offset': ?offset,
        'limit': ?limit,
      },
    );
    return PaginatedList<Recipe>.fromJson(
      ensureMap(response),
      (json) => Recipe.fromJson(ensureMap(json)),
    );
  }

  Future<Recipe> findOne(String recipeId) async {
    final response = await sendRequest(method: .get, path: '/$recipeId');
    return Recipe.fromJson(ensureMap(response));
  }

  Future<Recipe> create(Recipe recipe) async {
    final response = await sendRequest(method: .post, body: recipe.toJson());
    return Recipe.fromJson(ensureMap(response));
  }

  Future<Recipe> update(String id, Recipe recipe) async {
    final response = await sendRequest(method: .patch, path: '/$id', body: recipe.toJson());
    return Recipe.fromJson(ensureMap(response));
  }

  Future<void> delete(String id) async {
    await sendRequest(method: .delete, path: '/$id');
  }

  Future<Recipe> import(String url, {bool update = false}) async {
    final response = await sendRequest(
      method: .post,
      path: '/import',
      body: {'url': url, 'update': update},
    );
    return Recipe.fromJson(ensureMap(response));
  }

  Future<void> save(String recipeId) async {
    await sendRequest(method: .post, path: '/$recipeId/favorite');
  }

  Future<void> unsave(String recipeId) async {
    await sendRequest(method: .delete, path: '/$recipeId/favorite');
  }

  // Ingredients

  Future<RecipeIngredient> createIngredient(String recipeId, RecipeIngredient ingredient) async {
    final response = await sendRequest(
      method: .post,
      path: '/$recipeId/ingredients',
      body: ingredient.toJson(),
    );
    return RecipeIngredient.fromJson(ensureMap(response));
  }

  Future<RecipeIngredient> updateIngredient(
    String recipeId,
    String ingredientId,
    RecipeIngredient ingredient,
  ) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$recipeId/ingredients/$ingredientId',
      body: ingredient.toJson(),
    );
    return RecipeIngredient.fromJson(ensureMap(response));
  }

  Future<void> deleteIngredient(String recipeId, String ingredientId) async {
    await sendRequest(method: .delete, path: '/$recipeId/ingredients/$ingredientId');
  }

  // Instructions

  Future<RecipeInstruction> createInstruction(String recipeId, RecipeInstruction instruction) async {
    final response = await sendRequest(
      method: .post,
      path: '/$recipeId/instructions',
      body: instruction.toJson(),
    );
    return RecipeInstruction.fromJson(ensureMap(response));
  }

  Future<RecipeInstruction> updateInstruction(
    String recipeId,
    String instructionId,
    RecipeInstruction instruction,
  ) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$recipeId/instructions/$instructionId',
      body: instruction.toJson(),
    );
    return RecipeInstruction.fromJson(ensureMap(response));
  }

  Future<void> deleteInstruction(String recipeId, String instructionId) async {
    await sendRequest(method: .delete, path: '/$recipeId/instructions/$instructionId');
  }

  // Equipment

  Future<void> addEquipment(String recipeId, String equipmentId) async {
    await sendRequest(method: .post, path: '/$recipeId/equipment/$equipmentId');
  }

  Future<void> removeEquipment(String recipeId, String equipmentId) async {
    await sendRequest(method: .delete, path: '/$recipeId/equipment/$equipmentId');
  }
}
