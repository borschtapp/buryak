import 'repository.dart';
import '../models/publisher.dart';

class PublisherRepository extends Repository {
  PublisherRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/publishers',
    super.isAuth = true,
  });

  static Future<List<Publisher>> findAll({
    String? preload,
    String? q,
    String? sort,
    String? order,
    int? page,
    int? limit,
    int? offset,
  }) async {
    ResponseBody response =
        await PublisherRepository(
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
    return (response['data'] as List).map<Publisher>((json) => Publisher.fromJson(json)).toList();
  }
}
