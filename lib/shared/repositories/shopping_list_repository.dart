import 'repository.dart';
import '../models/shopping_list.dart';

class ShoppingListRepository extends Repository {
  ShoppingListRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/shoppinglist',
    super.isAuth = true,
  });

  static Future<List<ShoppingList>> findAll({int? page, int? limit}) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.get,
        ).sendRequest(
          queryParams: {
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<ShoppingList>((json) => ShoppingList.fromJson(json)).toList();
  }

  static Future<ShoppingList> create(String name, {double? quantity, String? unitId}) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.post,
        ).sendRequest(
          body: {
            'name': name,
            'quantity': ?quantity,
            'unit_id': ?unitId,
          },
        );
    return ShoppingList.fromJson(response);
  }

  static Future<ShoppingList> update(String id, {String? name, double? quantity, bool? isBought}) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.patch,
          path: '/$id',
        ).sendRequest(
          body: {
            'name': ?name,
            'quantity': ?quantity,
            'is_bought': ?isBought,
          },
        );
    return ShoppingList.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await ShoppingListRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
  }
}
