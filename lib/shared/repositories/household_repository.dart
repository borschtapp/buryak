import 'repository.dart';
import '../models/household.dart';
import '../models/user.dart';

class HouseholdRepository extends Repository {
  HouseholdRepository({
    required super.method,
    super.path = '',
    super.module = '/api/v1/households',
    super.isAuth = true,
  });

  static Future<Household> findOne(String id) async {
    ResponseBody response = await HouseholdRepository(
      method: RequestMethod.get,
      path: '/$id',
    ).sendRequest();
    return Household.fromJson(response);
  }

  static Future<Household> update(String id, String name) async {
    ResponseBody response =
        await HouseholdRepository(
          method: RequestMethod.patch,
          path: '/$id',
        ).sendRequest(
          body: {'name': name},
        );
    return Household.fromJson(response);
  }

  static Future<List<User>> findMembers(String id, {int? page, int? limit}) async {
    ResponseBody response =
        await HouseholdRepository(
          method: RequestMethod.get,
          path: '/$id/members',
        ).sendRequest(
          queryParams: {
            'page': ?page,
            'limit': ?limit,
          },
        );
    return (response['data'] as List).map<User>((json) => User.fromJson(json)).toList();
  }

  static Future<User> addMember(String id, String email) async {
    ResponseBody response =
        await HouseholdRepository(
          method: RequestMethod.post,
          path: '/$id/members',
        ).sendRequest(
          body: {'email': email},
        );
    return User.fromJson(response);
  }

  static Future<void> removeMember(String id, String userId) async {
    await HouseholdRepository(
      method: RequestMethod.delete,
      path: '/$id/members/$userId',
    ).sendRequest();
  }
}
