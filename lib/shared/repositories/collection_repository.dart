import 'repository.dart';
import '../models/collection.dart';

class CollectionRepository extends Repository {
  CollectionRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/collections',
    super.isAuth = true,
  });

  static Future<List<Collection>> findAll({int? page, int? limit}) async {
    ResponseBody response = await CollectionRepository(
      method: RequestMethod.get,
    ).sendRequest(queryParams: {'page': ?page, 'limit': ?limit});
    return (response['data'] as List).map<Collection>((json) => Collection.fromJson(json)).toList();
  }

  static Future<Collection> findOne(String id) async {
    ResponseBody response = await CollectionRepository(
      method: RequestMethod.get,
      path: '/$id',
    ).sendRequest();
    return Collection.fromJson(response);
  }

  static Future<Collection> create(String name, {String? description}) async {
    ResponseBody response =
        await CollectionRepository(
          method: RequestMethod.post,
        ).sendRequest(
          body: {
            'name': name,
            'description': ?description,
          },
        );
    return Collection.fromJson(response);
  }

  static Future<Collection> update(
    String id, {
    String? name,
    String? description,
    List<String>? recipeIds,
  }) async {
    ResponseBody response =
        await CollectionRepository(
          method: RequestMethod.patch,
          path: '/$id',
        ).sendRequest(
          body: {
            'name': ?name,
            'description': ?description,
            'recipe_ids': ?recipeIds,
          },
        );
    return Collection.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await CollectionRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
  }
}
