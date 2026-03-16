import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository.dart';
import '../models/household.dart';
import '../models/user.dart';
import '../models/user_token.dart';
import '../models/paginated_list.dart';

part 'household_repository.g.dart';

@Riverpod(keepAlive: true)
HouseholdRepository householdRepository(Ref ref) => HouseholdRepository(ref: ref);

class HouseholdRepository extends Repository {
  const HouseholdRepository({required super.ref}) : super(module: '/api/v1/households');

  Future<Household> findOne(String id) async {
    final response = await sendRequest(method: .get, path: '/$id');
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

  Future<UserToken> createInvite(String id) async {
    final response = await sendRequest(
      method: .post,
      path: '/$id/invites',
    );
    return UserToken.fromJson(ensureMap(response));
  }

  Future<void> revokeInvite(String id, String code) async {
    await sendRequest(method: .delete, path: '/$id/invites/$code');
  }

  Future<void> joinHousehold(String code) async {
    await sendRequest(
      method: .post,
      path: '/invites/join',
      body: {'code': code},
    );
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
}
