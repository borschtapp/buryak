import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/food.dart';
import '../models/food_price.dart';
import '../models/paginated_list.dart';
import 'repository.dart';

part 'food_repository.g.dart';

@Riverpod(keepAlive: true)
FoodRepository foodRepository(Ref ref) => FoodRepository(ref: ref, client: ref.watch(httpClientProvider));

class FoodRepository extends Repository {
  const FoodRepository({required super.ref, super.client}) : super(module: '/api/v1/food');

  Future<PaginatedList<Food>> findAll({String? q, int? limit, int? offset}) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'q': ?q,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<Food>.fromJson(
      ensureMap(response),
      (json) => Food.fromJson(ensureMap(json)),
    );
  }

  Future<Food> update(
    String foodId, {
    String? name,
    String? description,
    String? defaultUnitId,
    bool? pantry,
  }) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$foodId',
      body: {
        'name': ?name,
        'description': ?description,
        'default_unit_id': ?defaultUnitId,
        'pantry': ?pantry,
      },
    );
    return Food.fromJson(ensureMap(response));
  }

  Future<void> merge(String foodId, String mergeIntoId) async {
    await sendRequest(
      method: .post,
      path: '/$foodId/merge',
      body: {'merge_into': mergeIntoId},
    );
  }

  Future<PaginatedList<FoodPrice>> findPrices(String foodId, {int? limit, int? offset}) async {
    final response = await sendRequest(
      method: .get,
      path: '/$foodId/price',
      queryParams: {
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<FoodPrice>.fromJson(
      ensureMap(response),
      (json) => FoodPrice.fromJson(ensureMap(json)),
    );
  }

  Future<FoodPrice> recordPrice(String foodId, double price, double amount, String unitId) async {
    final response = await sendRequest(
      method: .post,
      path: '/$foodId/price',
      body: {
        'price': price,
        'amount': amount,
        'unit_id': unitId,
      },
    );
    return FoodPrice.fromJson(ensureMap(response));
  }

  Future<void> deletePrice(String foodId, String priceId) async {
    await sendRequest(method: .delete, path: '/$foodId/price/$priceId');
  }
}
