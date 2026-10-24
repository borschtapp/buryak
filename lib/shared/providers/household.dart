import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/household.dart';
import '../models/user_token.dart';
import '../repositories/household_repository.dart';
import '../util/logger.dart';
import 'user.dart';

part 'household.g.dart';

// Run with `tsx.get(householdProvider.notifier)`.
final updateHouseholdMutation = Mutation<void>(label: 'updateHousehold');
final joinHouseholdMutation = Mutation<void>(label: 'joinHousehold');
final inviteViaEmailMutation = Mutation<void>(label: 'inviteViaEmail');
final generateInviteMutation = Mutation<UserToken>(label: 'generateInvite');
final leaveHouseholdMutation = Mutation<void>(label: 'leaveHousehold');

/// Key it with the member id (`removeMemberMutation(userId)`), since removals can overlap.
final removeMemberMutation = Mutation<void>(label: 'removeMember');

@riverpod
class HouseholdNotifier extends _$HouseholdNotifier {
  @override
  FutureOr<Household?> build() async {
    final session = ref.watch(sessionProvider);
    if (session == null || session.householdId.isEmpty) {
      if (session != null) {
        logger.d('HouseholdNotifier: user ${session.userId} has no householdId');
      }
      return null;
    }

    final repo = ref.read(householdRepositoryProvider);
    try {
      final household = await repo.findOne(
        session.householdId,
        preload: [.members, .invites],
      );

      return household;
    } catch (e, st) {
      logger.e('HouseholdNotifier: Error loading household ${session.householdId}', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateHousehold({String? name, String? currency}) async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(householdRepositoryProvider);
    final updated = await repo.update(current.id, name: name ?? current.name, currency: currency);

    state = AsyncValue.data(
      current.copyWith(
        name: updated.name,
        currency: updated.currency,
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
    final response = await ref.read(householdRepositoryProvider).joinHousehold(code);
    // Switches the session to the new household, which rebuilds this notifier
    // and every other household-scoped cache.
    await ref.read(authProvider.notifier).updateUser(response);
    // Still reload when the code was for the current household, so its members are fresh.
    // Last step: rebuilding replaces this notifier, so nothing after it may use ref or state.
    ref.invalidateSelf();
  }

  Future<void> leaveHousehold() async {
    final response = await ref.read(householdRepositoryProvider).leaveHousehold();
    // Switches the session off this household, which rebuilds this notifier
    // and every other household-scoped cache.
    await ref.read(authProvider.notifier).updateUser(response);
  }
}
