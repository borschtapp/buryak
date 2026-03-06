import 'repository.dart';
import '../models/publisher.dart';

class PublisherRepository extends Repository {
  PublisherRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/publishers',
    super.isAuth = true,
  });

  static Future<List<Publisher>> findAll({int? page, int? limit}) async {
    ResponseBody response =
        await PublisherRepository(
          method: RequestMethod.get,
        ).sendRequest(
          queryParams: {
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<Publisher>((json) => Publisher.fromJson(json)).toList();
  }
}
