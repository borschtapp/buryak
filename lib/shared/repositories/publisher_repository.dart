import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/paginated_list.dart';
import '../models/publisher.dart';
import 'repository.dart';

part 'publisher_repository.g.dart';

// ignore: constant_identifier_names
enum PublisherPreload { feeds, images, last3_recipes, total_recipes }

@Riverpod(keepAlive: true)
PublisherRepository publisherRepository(Ref ref) => PublisherRepository(ref: ref, client: ref.watch(httpClientProvider));

class PublisherRepository extends Repository {
  const PublisherRepository({required super.ref, super.client}) : super(module: '/api/v1/publishers');

  Future<PaginatedList<Publisher>> findAll({
    List<PublisherPreload>? preload,
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
    return PaginatedList<Publisher>.fromJson(
      ensureMap(response),
      (json) => Publisher.fromJson(ensureMap(json)),
    );
  }
}
