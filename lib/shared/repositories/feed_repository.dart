import 'repository.dart';
import '../models/feed.dart';
import '../models/recipe.dart';

class FeedRepository extends Repository {
  FeedRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/feeds',
    super.isAuth = true,
  });

  static Future<List<Feed>> findAll({
    required String preload,
    String? q,
    String? sort,
    String? order,
    int? page,
    int? limit,
    int? offset,
  }) async {
    ResponseBody response =
        await FeedRepository(
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
    return (response['data'] as List).map<Feed>((json) => Feed.fromJson(json)).toList();
  }

  static Future<Feed> subscribe(String url) async {
    ResponseBody response =
        await FeedRepository(
          method: RequestMethod.post,
        ).sendRequest(
          body: {'url': url},
        );
    return Feed.fromJson(response);
  }

  static Future<void> unsubscribe(String id) async {
    await FeedRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
  }

  static Future<List<Recipe>> stream({int? page, int? limit}) async {
    ResponseBody response =
        await FeedRepository(
          method: RequestMethod.get,
          path: '/stream',
        ).sendRequest(
          queryParams: {
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }
}
