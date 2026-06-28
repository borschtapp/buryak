import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/food_price.dart';
import '../models/paginated_list.dart';
import '../models/recipe_cost_estimate.dart';
import '../models/unit.dart';
import '../repositories/food_repository.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/unit_repository.dart';

part 'recipe_price.g.dart';

@riverpod
Future<RecipeCostEstimate> recipeCostEstimate(Ref ref, String recipeId) {
  return ref.watch(recipeRepositoryProvider).estimateCost(recipeId);
}

@riverpod
Future<PaginatedList<FoodPrice>> foodPrices(Ref ref, String foodId) {
  return ref.watch(foodRepositoryProvider).findPrices(foodId, limit: 20);
}

@Riverpod(keepAlive: true)
Future<List<Unit>> allUnits(Ref ref) async {
  final page = await ref.watch(unitRepositoryProvider).findAll(limit: 200);
  return page.data;
}

/// Session-level memory: remembers the unit a user picked per food when
/// the food has no server-side default_unit_id.
@Riverpod(keepAlive: true)
class FoodUnitPreferences extends _$FoodUnitPreferences {
  @override
  Map<String, String> build() => {};

  void setPreferred(String foodId, String unitId) {
    state = {...state, foodId: unitId};
  }
}
