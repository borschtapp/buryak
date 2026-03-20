import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/household.dart';
import '../../shared/models/user_token.dart';
import '../../shared/repositories/household_repository.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/logger.dart';

part 'notifier_household.g.dart';

@riverpod
class HouseholdNotifier extends _$HouseholdNotifier {
  @override
  FutureOr<Household?> build() async {
    final user = ref.watch(authProvider);
    if (user == null || user.householdId.isEmpty) {
      if (user != null) {
        logger.d(
          'HouseholdNotifier: user has no householdId (id: ${user.id}, email: ${user.email}, householdId: "${user.householdId}")',
        );
      }
      return null;
    }

    final repo = ref.read(householdRepositoryProvider);
    try {
      final household = await repo.findOne(
        user.householdId,
        preload: ['members', 'invites'],
      );

      return household;
    } catch (e, st) {
      logger.e('HouseholdNotifier: Error loading household ${user.householdId}', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await build());
  }

  Future<void> rename(String newName) async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(householdRepositoryProvider);
    final updated = await repo.update(current.id, newName);

    state = AsyncValue.data(
      current.copyWith(
        name: updated.name,
      ),
    );
  }

  Future<void> removeMember(String userId) async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(householdRepositoryProvider);
    await repo.removeMember(current.id, userId);

    state = AsyncValue.data(
      current.copyWith(
        members: current.members?.where((m) => m.id != userId).toList(),
      ),
    );
  }

  Future<UserToken> generateInvite() async {
    final current = state.value;
    if (current == null) throw Exception('No household');

    final repo = ref.read(householdRepositoryProvider);
    final invite = await repo.createInvite(current.id);
    await reload(); // Refresh to show new invite
    return invite;
  }

  Future<void> inviteViaEmail(String email) async {
    final current = state.value;
    if (current == null) throw Exception('No household');

    final repo = ref.read(householdRepositoryProvider);
    await repo.createInvite(current.id, email: email);
    await reload(); // Refresh to show new invite
  }

  Future<List<UserToken>> listInvites() async {
    final current = state.value;
    if (current == null) return [];

    return ref.read(householdRepositoryProvider).listInvites(current.id);
  }

  Future<void> revokeInvite(String code) async {
    final current = state.value;
    if (current == null) return;

    await ref.read(householdRepositoryProvider).revokeInvite(code);
  }

  Future<void> joinHousehold(String code) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(householdRepositoryProvider);
      final response = await repo.joinHousehold(code);

      // Refresh the access token and household data
      await ref.read(authProvider.notifier).updateFromAuthResponse(response);

      await reload();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> leaveHousehold() async {
    final repo = ref.read(householdRepositoryProvider);
    final response = await repo.leaveHousehold();

    final auth = ref.read(authProvider.notifier);
    await auth.updateFromAuthResponse(response);
  }
}
