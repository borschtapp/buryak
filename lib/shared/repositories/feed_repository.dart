import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/feed.dart';
import '../models/paginated_list.dart';
import '../models/recipe.dart';
import '../models/recipe_filter.dart';
import 'recipe_repository.dart';
import 'repository.dart';

part 'feed_repository.g.dart';

// ignore: constant_identifier_names
enum FeedPreload { publisher, total_recipes, last3_recipes }

@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) => FeedRepository(ref: ref, client: ref.watch(httpClientProvider));

class FeedRepository extends Repository {
  const FeedRepository({required super.ref, super.client}) : super(module: '/api/v1/feeds');

  Future<PaginatedList<Feed>> findAll({
    List<FeedPreload>? preload,
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
    List<RecipePreload>? preload,
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
        'preload': preload?.map((e) => e.name).join(','),
        'sort': f.sort.name,
        'order': f.order.name,
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
