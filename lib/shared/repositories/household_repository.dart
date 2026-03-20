import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/household.dart';
import '../models/user.dart';
import '../models/user_token.dart';
import '../models/paginated_list.dart';
import '../models/invite_info.dart';

part 'household_repository.g.dart';

@Riverpod(keepAlive: true)
HouseholdRepository householdRepository(Ref ref) => HouseholdRepository(ref: ref);

class HouseholdRepository extends Repository {
  const HouseholdRepository({required super.ref}) : super(module: '/api/v1/households');

  Future<Household> findOne(String id, {List<String>? preload}) async {
    final response = await sendRequest(
      method: .get,
      path: '/$id',
      queryParams: {
        'preload': preload?.join(','),
      },
    );
    return Household.fromJson(ensureMap(response));
  }

  Future<Household> update(String id, String name) async {
    final response = await sendRequest(
      method: .patch,
      path: '/$id',
      body: {'name': name},
    );
    return Household.fromJson(ensureMap(response));
  }

  Future<List<UserToken>> listInvites(String id) async {
    final response = await sendRequest(
      method: RequestMethod.get,
      path: '/$id/invites',
    );
    final list = ensureList(response);
    return list.map((e) => UserToken.fromJson(ensureMap(e))).toList();
  }

  Future<UserToken> createInvite(String id, {String? email}) async {
    final response = await sendRequest(
      method: .post,
      path: '/$id/invites',
      body: email != null ? {'email': email} : null,
    );
    return UserToken.fromJson(ensureMap(response));
  }

  Future<void> revokeInvite(String code) async {
    await sendRequest(method: .delete, path: '/invites/$code');
  }

  Future<Map<String, dynamic>> joinHousehold(String code) async {
    final response = await sendRequest(
      method: .post,
      path: '/invites/$code/join',
    );
    return ensureMap(response);
  }

  Future<PaginatedList<User>> findMembers(String householdId) async {
    final response = await sendRequest(
      method: RequestMethod.get,
      path: '/$householdId/members',
    );
    return PaginatedList<User>.fromJson(
      ensureMap(response),
      (json) => User.fromJson(ensureMap(json)),
    );
  }

  Future<void> removeMember(String id, String userId) async {
    await sendRequest(method: .delete, path: '/$id/members/$userId');
  }

  Future<Map<String, dynamic>> leaveHousehold() async {
    final response = await sendRequest(
      method: .post,
      path: '/leave',
    );
    return ensureMap(response);
  }

  Future<InviteInfo> getInviteInfo(String code) async {
    final response = await sendRequest(
      method: .get,
      path: '/invites/$code/info',
      authOverride: false,
    );
    return InviteInfo.fromJson(ensureMap(response));
  }
}
