import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/publisher.dart';
import '../models/paginated_list.dart';

part 'publisher_repository.g.dart';

@Riverpod(keepAlive: true)
PublisherRepository publisherRepository(Ref ref) => PublisherRepository(ref: ref);

class PublisherRepository extends Repository {
  const PublisherRepository({required super.ref}) : super(module: '/api/v1/publishers');

  Future<PaginatedList<Publisher>> findAll({
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
    return PaginatedList<Publisher>.fromJson(
      ensureMap(response),
      (json) => Publisher.fromJson(ensureMap(json)),
    );
  }
}
