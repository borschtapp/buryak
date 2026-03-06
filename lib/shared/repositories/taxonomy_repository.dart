import 'repository.dart';
import '../models/taxonomy.dart';

class TaxonomyRepository extends Repository {
  TaxonomyRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/taxonomies',
    super.isAuth = true,
  });

  static Future<List<Taxonomy>> findAll({String? type, int? page, int? limit}) async {
    ResponseBody response =
        await TaxonomyRepository(
          method: RequestMethod.get,
        ).sendRequest(
          queryParams: {
            'type': ?type,
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<Taxonomy>((json) => Taxonomy.fromJson(json)).toList();
  }
}
