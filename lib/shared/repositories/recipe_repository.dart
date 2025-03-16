import 'repository.dart';
import '../models/recipe.dart';

class RecipeRepository extends Repository {
  RecipeRepository({required super.method, super.path = '', super.module = '/recipes', super.isAuth = true});

  static Future<List<Recipe>> findAll() async {
    ResponseBody response = await RecipeRepository(method: RequestMethod.get).sendRequest();
    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  static Future<Recipe> findOne(int recipeId) async {
    ResponseBody response = await RecipeRepository(method: RequestMethod.get, path: '/$recipeId').sendRequest();
    return Recipe.fromJson(response);
  }

  static Future<List<Recipe>> explore() async {
    ResponseBody response = await RecipeRepository(method: RequestMethod.get, path: '/explore').sendRequest();
    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }

  static Future<Recipe> scrape(String url) async {
    ResponseBody response =
        await RecipeRepository(method: RequestMethod.get, path: '/scrape').sendRequest(queryParams: {'url': url});
    return Recipe.fromJson(response);
  }

  static Future<void> save(int recipeId) async {
    await RecipeRepository(method: RequestMethod.post, path: '/$recipeId/save').sendRequest();
  }

  static Future<void> unsave(int recipeId) async {
    await RecipeRepository(method: RequestMethod.delete, path: '/$recipeId/save').sendRequest();
  }
}
