import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/feed.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import '../models/paginated_list.dart';

part 'feed_repository.g.dart';

@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) => FeedRepository(ref: ref);

class FeedRepository extends Repository {
  const FeedRepository({required super.ref}) : super(module: '/api/v1/feeds');

  Future<PaginatedList<Feed>> findAll({
    String? preload,
    String? q,
    String? sort,
    String? order,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'preload': ?preload,
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<Feed>.fromJson(
      ensureMap(response),
      (json) => Feed.fromJson(ensureMap(json)),
    );
  }

  Future<Feed> subscribe(String url) async {
    final response = await sendRequest(
      method: .post,
      body: {'url': url},
    );
    return Feed.fromJson(ensureMap(response));
  }

  Future<void> unsubscribe(String id) async {
    await sendRequest(method: .delete, path: '/$id');
  }

  Future<PaginatedList<Recipe>> stream({
    String? preload,
    RecipeFilter? filter,
    int? limit,
    int? offset,
  }) async {
    final f = filter ?? const RecipeFilter();
    final response = await sendRequest(
      method: .get,
      path: '/stream',
      queryParams: {
        'q': ?f.q,
        'taxonomies': ?f.taxonomiesParam,
        'publishers': ?f.publishersParam,
        'authors': ?f.authorsParam,
        'equipment': ?f.equipmentParam,
        'cook_time_max': ?f.cookTimeMax,
        'total_time_max': ?f.totalTimeMax,
        'preload': ?preload,
        'sort': f.sort,
        'order': f.order,
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
