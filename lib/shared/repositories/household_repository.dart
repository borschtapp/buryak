import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/household.dart';
import '../models/invite_info.dart';
import '../models/paginated_list.dart';
import '../models/user.dart';
import '../models/user_token.dart';
import 'repository.dart';

part 'household_repository.g.dart';

enum HouseholdPreload { members, invites }

@Riverpod(keepAlive: true)
HouseholdRepository householdRepository(Ref ref) => HouseholdRepository(ref: ref, client: ref.watch(httpClientProvider));

class HouseholdRepository extends Repository {
  const HouseholdRepository({required super.ref, super.client}) : super(module: '/api/v1/households');

  Future<Household> findOne(String id, {List<HouseholdPreload>? preload}) async {
    final response = await sendRequest(
      method: .get,
      path: '/$id',
      queryParams: {
        'preload': preload?.map((e) => e.name).join(','),
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
      method: .get,
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

  Future<User> joinHousehold(String code) async {
    final response = await sendRequest(
      method: .post,
      path: '/invites/$code/join',
    );
    return User.fromJson(ensureMap(response));
  }

  Future<PaginatedList<User>> findMembers(String householdId) async {
    final response = await sendRequest(
      method: .get,
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

  Future<User> leaveHousehold() async {
    final response = await sendRequest(
      method: .post,
      path: '/leave',
    );
    return User.fromJson(ensureMap(response));
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
