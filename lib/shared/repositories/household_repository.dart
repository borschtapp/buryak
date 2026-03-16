import 'repository.dart';
import '../models/household.dart';
import '../models/user.dart';
import '../models/user_token.dart';

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

  static Future<void> removeMember(String id, String userId) async {
    await HouseholdRepository(
      method: RequestMethod.delete,
      path: '/$id/members/$userId',
    ).sendRequest();
  }

  // Invite management

  static Future<List<UserToken>> listInvites(String id) async {
    ResponseBody response = await HouseholdRepository(
      method: RequestMethod.get,
      path: '/$id/invites',
    ).sendRequest();
    return (response as List).map<UserToken>((json) => UserToken.fromJson(json)).toList();
  }

  static Future<UserToken> createInvite(String id) async {
    ResponseBody response = await HouseholdRepository(
      method: RequestMethod.post,
      path: '/$id/invites',
    ).sendRequest();
    return UserToken.fromJson(response);
  }

  static Future<void> deleteInvite(String id, String code) async {
    await HouseholdRepository(
      method: RequestMethod.delete,
      path: '/$id/invites/$code',
    ).sendRequest();
  }

  static Future<void> joinHousehold(String code) async {
    await HouseholdRepository(
      method: RequestMethod.post,
      path: '/invites/join',
    ).sendRequest(body: {'code': code});
  }
}
