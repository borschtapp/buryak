import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/meal_plan.dart';
import '../models/paginated_list.dart';
import 'repository.dart';

part 'meal_plan_repository.g.dart';

@Riverpod(keepAlive: true)
MealPlanRepository mealPlanRepository(Ref ref) => MealPlanRepository(ref: ref, client: ref.watch(httpClientProvider));

class MealPlanRepository extends Repository {
  const MealPlanRepository({required super.ref, super.client}) : super(module: '/api/v1/mealplan');

  Future<PaginatedList<MealPlan>> findAll({
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        if (from != null) 'from': DateFormat('yyyy-MM-dd').format(from),
        if (to != null) 'to': DateFormat('yyyy-MM-dd').format(to),
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<MealPlan>.fromJson(
      ensureMap(response),
      (json) => MealPlan.fromJson(ensureMap(json)),
    );
  }

  Future<MealPlan> create(
    DateTime date,
    MealType mealType, {
    String? description,
    int? servings,
    String? recipeId,
  }) async {
    final response = await sendRequest(
      method: .post,
      body: {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'meal_type': mealType.name,
        'description': ?description,
        'servings': ?servings,
        'recipe_id': ?recipeId,
      },
    );
    return MealPlan.fromJson(ensureMap(response));
  }

  Future<MealPlan> update(
    String id, {
    DateTime? date,
    MealType? mealType,
    String? description,
    int? servings,
    String? recipeId,
  }) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$id',
      body: {
        if (date != null) 'date': DateFormat('yyyy-MM-dd').format(date),
        'meal_type': ?mealType?.name,
        'description': ?description,
        'servings': ?servings,
        'recipe_id': ?recipeId,
      },
    );
    return MealPlan.fromJson(ensureMap(response));
  }

  Future<void> delete(String id) async {
    await sendRequest(method: .delete, path: '/$id');
  }
}
