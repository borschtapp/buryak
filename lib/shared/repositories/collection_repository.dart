import 'repository.dart';
import '../models/collection.dart';
import '../models/recipe.dart';
import '../providers/collection_notifier.dart';

class CollectionRepository extends Repository {
  CollectionRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/collections',
    super.isAuth = true,
  });

  static Future<List<Collection>> findAll({
    required String preload,
    String? q,
    String? sort,
    String? order,
    int? page,
    int? limit,
    int? offset,
  }) async {
    ResponseBody response = await CollectionRepository(
      method: RequestMethod.get,
    ).sendRequest(
      queryParams: {
        'preload': preload,
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'page': ?page,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
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
    Collection created = Collection.fromJson(response);
    CollectionRefreshNotifier().notify();
    return created;
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
    Collection updated = Collection.fromJson(response);
    CollectionRefreshNotifier().notify();
    return updated;
  }

  static Future<void> delete(String id) async {
    await CollectionRepository(method: RequestMethod.delete, path: '/$id').sendRequest();
    CollectionRefreshNotifier().notify();
  }

  static Future<void> addRecipe(String collectionId, String recipeId) async {
    await CollectionRepository(
      method: RequestMethod.post,
      path: '/$collectionId/recipes/$recipeId',
    ).sendRequest();
    CollectionRefreshNotifier().notify();
  }

  static Future<void> removeRecipe(String collectionId, String recipeId) async {
    await CollectionRepository(
      method: RequestMethod.delete,
      path: '/$collectionId/recipes/$recipeId',
    ).sendRequest();
    CollectionRefreshNotifier().notify();
  }

  static Future<List<Recipe>> getRecipes(String collectionId, {
    required String preload,
    String? q,
    String? sort,
    String? order,
    int? page,
    int? limit,
    int? offset,
  }) async {
    ResponseBody response = await CollectionRepository(
      method: RequestMethod.get,
      path: '/$collectionId/recipes',
    ).sendRequest(
      queryParams: {
        'preload': preload,
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'page': ?page,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return (response['data'] as List).map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }
}
