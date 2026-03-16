import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/paginated_list.dart';

part 'shopping_list_repository.g.dart';

@Riverpod(keepAlive: true)
ShoppingListRepository shoppingListRepository(Ref ref) => ShoppingListRepository(ref: ref);

class ShoppingListRepository extends Repository {
  const ShoppingListRepository({required super.ref, super.client}) : super(module: '/api/v1/shoppinglists');

  Future<PaginatedList<ShoppingList>> findAll({int? limit, int? offset}) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<ShoppingList>.fromJson(
      ensureMap(response),
      (json) => ShoppingList.fromJson(ensureMap(json)),
    );
  }

  Future<PaginatedList<ShoppingItem>> findItems(String listId, {int? limit, int? offset}) async {
    final response = await sendRequest(
      method: .get,
      path: '/$listId/items',
      queryParams: {
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<ShoppingItem>.fromJson(
      ensureMap(response),
      (json) => ShoppingItem.fromJson(ensureMap(json)),
    );
  }

  Future<ShoppingList> create(String name, {bool? isDefault}) async {
    final response = await sendRequest(
      method: .post,
      body: {
        'name': name,
        'is_default': ?isDefault,
      },
    );
    return ShoppingList.fromJson(ensureMap(response));
  }

  Future<ShoppingList> update(String id, {String? name, bool? isDefault}) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$id',
      body: {
        'name': ?name,
        'is_default': ?isDefault,
      },
    );
    return ShoppingList.fromJson(ensureMap(response));
  }

  Future<void> delete(String id) async {
    await sendRequest(method: .delete, path: '/$id');
  }

  Future<ShoppingItem> createItem(String listId, String text, {double? amount, String? unitId, String? foodId}) async {
    final response = await sendRequest(
      method: .post,
      path: '/$listId/items',
      body: {
        'text': text,
        'amount': ?amount,
        'unit_id': ?unitId,
        'food_id': ?foodId,
      },
    );
    return ShoppingItem.fromJson(ensureMap(response));
  }

  Future<ShoppingItem> updateItem(String listId, String itemId, {String? text, double? amount, bool? isBought}) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$listId/items/$itemId',
      body: {
        'text': ?text,
        'amount': ?amount,
        'is_bought': ?isBought,
      },
    );
    return ShoppingItem.fromJson(ensureMap(response));
  }

  Future<void> deleteItem(String listId, String itemId) async {
    await sendRequest(method: .delete, path: '/$listId/items/$itemId');
  }
}
