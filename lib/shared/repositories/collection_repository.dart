import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/collection.dart';
import '../models/paginated_list.dart';
import '../models/recipe.dart';
import 'recipe_repository.dart';
import 'repository.dart';

part 'collection_repository.g.dart';

// ignore: constant_identifier_names
enum CollectionPreload { total_recipes, last3_recipes }

@Riverpod(keepAlive: true)
CollectionRepository collectionRepository(Ref ref) => CollectionRepository(ref: ref, client: ref.watch(httpClientProvider));

class CollectionRepository extends Repository {
  const CollectionRepository({required super.ref, super.client}) : super(module: '/api/v1/collections');

  Future<PaginatedList<Collection>> findAll({
    List<CollectionPreload>? preload,
    String? q,
    String? sort,
    String? order,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'preload': preload?.map((e) => e.name).join(','),
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<Collection>.fromJson(
      ensureMap(response),
      (json) => Collection.fromJson(ensureMap(json)),
    );
  }

  Future<Collection> findOne(String id) async {
    final response = await sendRequest(method: .get, path: '/$id');
    return Collection.fromJson(ensureMap(response));
  }

  Future<Collection> create(String name, {String? description}) async {
    final response = await sendRequest(
      method: .post,
      body: {
        'name': name,
        'description': ?description,
      },
    );
    return Collection.fromJson(ensureMap(response));
  }

  Future<Collection> update(
    String id, {
    String? name,
    String? description,
    List<String>? recipeIds,
  }) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$id',
      body: {
        'name': ?name,
        'description': ?description,
        'recipe_ids': ?recipeIds,
      },
    );
    return Collection.fromJson(ensureMap(response));
  }

  Future<void> delete(String id) async {
    await sendRequest(method: .delete, path: '/$id');
  }

  Future<void> addRecipe(String collectionId, String recipeId) async {
    await sendRequest(method: .post, path: '/$collectionId/recipes/$recipeId');
  }

  Future<void> removeRecipe(String collectionId, String recipeId) async {
    await sendRequest(method: .delete, path: '/$collectionId/recipes/$recipeId');
  }

  Future<PaginatedList<Recipe>> getRecipes(
    String collectionId, {
    List<RecipePreload>? preload,
    String? q,
    String? sort,
    String? order,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      path: '/$collectionId/recipes',
      queryParams: {
        'preload': preload?.map((e) => e.name).join(','),
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<Recipe>.fromJson(
      ensureMap(response),
      (json) => Recipe.fromJson(ensureMap(json)),
    );
  }
}
