import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/paginated_list.dart';
import '../models/taxonomy.dart';
import 'repository.dart';

part 'taxonomy_repository.g.dart';

// ignore: constant_identifier_names
enum TaxonomyPreload { total_recipes }

@Riverpod(keepAlive: true)
TaxonomyRepository taxonomyRepository(Ref ref) => TaxonomyRepository(ref: ref, client: ref.watch(httpClientProvider));

class TaxonomyRepository extends Repository {
  const TaxonomyRepository({required super.ref, super.client}) : super(module: '/api/v1/taxonomies');

  Future<PaginatedList<Taxonomy>> findAll({
    String? type,
    List<TaxonomyPreload>? preload,
    String? scope,
    String? q,
    String? sort,
    String? order,
    int? limit,
    int? offset,
  }) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'type': ?type,
        'preload': preload?.map((e) => e.name).join(','),
        'scope': ?scope,
        'q': ?q,
        'sort': ?sort,
        'order': ?order,
        'limit': ?limit,
        'offset': ?offset,
      },
    );
    return PaginatedList<Taxonomy>.fromJson(
      ensureMap(response),
      (json) => Taxonomy.fromJson(ensureMap(json)),
    );
  }
}
