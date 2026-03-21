import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/paginated_list.dart';
import '../models/taxonomy.dart';
import 'repository.dart';

part 'taxonomy_repository.g.dart';

@Riverpod(keepAlive: true)
TaxonomyRepository taxonomyRepository(Ref ref) => TaxonomyRepository(ref: ref, client: ref.watch(httpClientProvider));

class TaxonomyRepository extends Repository {
  const TaxonomyRepository({required super.ref, super.client}) : super(module: '/api/v1/taxonomies');

  Future<PaginatedList<Taxonomy>> findAll({String? type, int? limit, int? offset}) async {
    final response = await sendRequest(
      method: .get,
      queryParams: {
        'type': ?type,
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
