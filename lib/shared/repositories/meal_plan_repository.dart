import 'repository.dart';
import '../models/meal_plan.dart';

class MealPlanRepository extends Repository {
  MealPlanRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/mealplan',
    super.isAuth = true,
  });

  static Future<List<MealPlan>> findAll({
    String? from,
    String? to,
    int? page,
    int? limit,
  }) async {
    ResponseBody response =
        await MealPlanRepository(
          method: RequestMethod.get,
        ).sendRequest(
          queryParams: {
            'from': ?from,
            'to': ?to,
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<MealPlan>((json) => MealPlan.fromJson(json)).toList();
  }

  static Future<MealPlan> create(
    String date,
    String mealType, {
    String? note,
    int? servings,
    String? recipeId,
  }) async {
    ResponseBody response =
        await MealPlanRepository(
          method: RequestMethod.post,
        ).sendRequest(
          body: {
            'date': date,
            'meal_type': mealType,
            'note': ?note,
            'servings': ?servings,
            'recipe_id': ?recipeId,
          },
        );
    return MealPlan.fromJson(response);
  }

  static Future<MealPlan> update(
    String id, {
    String? date,
    String? mealType,
    String? note,
    int? servings,
    String? recipeId,
  }) async {
    ResponseBody response =
        await MealPlanRepository(
          method: RequestMethod.patch,
          path: '/$id',
        ).sendRequest(
          body: {
            'date': ?date,
            'meal_type': ?mealType,
            'note': ?note,
            'servings': ?servings,
            'recipe_id': ?recipeId,
          },
        );
    return MealPlan.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await MealPlanRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
  }
}
