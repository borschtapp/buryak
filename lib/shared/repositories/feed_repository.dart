import 'repository.dart';
import '../models/feed.dart';
import '../models/recipe.dart';
import '../providers/feed_notifier.dart';

class FeedRepository extends Repository {
  FeedRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/feeds',
    super.isAuth = true,
  });

  static Future<List<Feed>> findAll({
    String? preload,
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
            'preload': ?preload,
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
    Feed feed = Feed.fromJson(response);
    FeedRefreshNotifier().notify(action: 'create', feedId: feed.id, data: feed);
    return feed;
  }

  static Future<void> unsubscribe(String id) async {
    await FeedRepository(
      method: RequestMethod.delete,
      path: '/$id',
    ).sendRequest();
  }

  static Future<List<Recipe>> stream({String? preload, int? page, int? limit}) async {
    ResponseBody response =
        await FeedRepository(
          method: RequestMethod.get,
          path: '/stream',
        ).sendRequest(
          queryParams: {
            'preload': ?preload,
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<Recipe>((json) => Recipe.fromJson(json)).toList();
  }
}
