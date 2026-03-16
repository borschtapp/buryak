import 'repository.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';

class ShoppingListRepository extends Repository {
  ShoppingListRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/shoppinglists',
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

  static Future<ShoppingList> create(String name) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.post,
        ).sendRequest(
          body: {'name': name},
        );
    return ShoppingList.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await ShoppingListRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
  }

  // Item management

  static Future<List<ShoppingItem>> findItems(String listId, {int? page, int? limit}) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.get,
          path: '/$listId/items',
        ).sendRequest(
          queryParams: {
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<ShoppingItem>((json) => ShoppingItem.fromJson(json)).toList();
  }

  static Future<ShoppingItem> createItem(String listId, {String? text, double? amount, String? foodId, String? unitId}) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.post,
          path: '/$listId/items',
        ).sendRequest(
          body: {
            'text': ?text,
            'amount': ?amount,
            'food_id': ?foodId,
            'unit_id': ?unitId,
          },
        );
    return ShoppingItem.fromJson(response);
  }

  static Future<ShoppingItem> updateItem(String listId, String itemId, {String? name, double? amount, bool? isBought}) async {
    ResponseBody response =
        await ShoppingListRepository(
          method: RequestMethod.patch,
          path: '/$listId/items/$itemId',
        ).sendRequest(
          body: {
            'name': ?name,
            'amount': ?amount,
            'is_bought': ?isBought,
          },
        );
    return ShoppingItem.fromJson(response);
  }

  static Future<void> deleteItem(String listId, String itemId) async {
    await ShoppingListRepository(
      method: RequestMethod.delete,
      path: '/$listId/items/$itemId',
    ).sendRequest();
  }
}
