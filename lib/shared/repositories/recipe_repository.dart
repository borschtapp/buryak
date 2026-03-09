import 'repository.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_instruction.dart';
import '../providers/recipe_notifier.dart';

class RecipeRepository extends Repository {
  RecipeRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/recipes',
    super.isAuth = true,
  });

  static Future<List<Recipe>> findAll({
    String? preload,
    int? page,
    int? limit,
    String? q,
    String? taxonomies,
    String? cuisine,
    String? sort,
    String? order,
    int? offset,
  }) async {
    ResponseBody response =
        await RecipeRepository(
          method: RequestMethod.get,
        ).sendRequest(
          queryParams: {
            'q': ?q,
            'taxonomies': ?taxonomies,
            'cuisine': ?cuisine,
            'preload': ?preload,
            'sort': ?sort,
            'order': ?order,
            'offset': ?offset,
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  static Future<Recipe> findOne(String recipeId) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.get,
      path: '/$recipeId',
    ).sendRequest();
    return Recipe.fromJson(response);
  }

  static Future<Recipe> create(Recipe recipe) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.post,
    ).sendRequest(body: recipe.toJson());
    Recipe created = Recipe.fromJson(response);
    RecipeRefreshNotifier().notify(action: 'create', data: created);
    return created;
  }

  static Future<Recipe> update(String id, Recipe recipe) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.patch,
      path: '/$id',
    ).sendRequest(body: recipe.toJson());
    Recipe updated = Recipe.fromJson(response);
    RecipeRefreshNotifier().notify(action: 'update', data: updated);
    return updated;
  }

  static Future<void> delete(String id) async {
    await RecipeRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
    RecipeRefreshNotifier().notify(action: 'delete', recipeId: id);
  }

  static Future<Recipe> import(String url, {bool update = false}) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.post,
      path: '/import',
    ).sendRequest(body: {'url': url, 'update': update});
    Recipe imported = Recipe.fromJson(response);
    RecipeRefreshNotifier().notify(action: 'create', data: imported);
    return imported;
  }

  static Future<void> save(String recipeId) async {
    await RecipeRepository(
      method: RequestMethod.post,
      path: '/$recipeId/favorite',
    ).sendRequest();
    RecipeRefreshNotifier().notify(action: 'save', recipeId: recipeId);
  }

  static Future<void> unsave(String recipeId) async {
    await RecipeRepository(
      method: RequestMethod.delete,
      path: '/$recipeId/favorite',
    ).sendRequest();
    RecipeRefreshNotifier().notify(action: 'unsave', recipeId: recipeId);
  }

  // Ingredients

  static Future<RecipeIngredient> createIngredient(String recipeId, RecipeIngredient ingredient) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.post,
      path: '/$recipeId/ingredients',
    ).sendRequest(body: ingredient.toJson());
    return RecipeIngredient.fromJson(response);
  }

  static Future<RecipeIngredient> updateIngredient(
    String recipeId,
    String ingredientId,
    RecipeIngredient ingredient,
  ) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.patch,
      path: '/$recipeId/ingredients/$ingredientId',
    ).sendRequest(body: ingredient.toJson());
    return RecipeIngredient.fromJson(response);
  }

  static Future<void> deleteIngredient(String recipeId, String ingredientId) async {
    await RecipeRepository(
      method: RequestMethod.delete,
      path: '/$recipeId/ingredients/$ingredientId',
    ).sendRequest();
  }

  // Instructions

  static Future<RecipeInstruction> createInstruction(String recipeId, RecipeInstruction instruction) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.post,
      path: '/$recipeId/instructions',
    ).sendRequest(body: instruction.toJson());
    return RecipeInstruction.fromJson(response);
  }

  static Future<RecipeInstruction> updateInstruction(
    String recipeId,
    String instructionId,
    RecipeInstruction instruction,
  ) async {
    ResponseBody response = await RecipeRepository(
      method: RequestMethod.patch,
      path: '/$recipeId/instructions/$instructionId',
    ).sendRequest(body: instruction.toJson());
    return RecipeInstruction.fromJson(response);
  }

  static Future<void> deleteInstruction(String recipeId, String instructionId) async {
    await RecipeRepository(
      method: RequestMethod.delete,
      path: '/$recipeId/instructions/$instructionId',
    ).sendRequest();
  }
}
