import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/providers/household.dart';
import '../../shared/providers/user.dart';
import '../../shared/util/extensions.dart';
import 'dialog_invite_user.dart';
import 'dialog_join_household.dart';
import 'dialog_rename_household.dart';

class HouseholdDetails extends HookConsumerWidget {
  const HouseholdDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);
    final householdAsync = ref.watch(householdProvider);

    if (userState == null) return const SizedBox.shrink();
    final currentUserId = userState.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: householdAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading household: $err'),
          data: (household) {
            if (household == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Household', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('You are not currently part of a household.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => showJoinHouseholdDialog(context),
                    icon: const Icon(Icons.login),
                    label: const Text('Join Household'),
                  ),
                ],
              );
            }

            final isOwner = household.ownerId == currentUserId;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        household.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showRenameHouseholdDialog(context),
                        tooltip: 'Rename Household',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (household.members != null)
                  ...household.members!.map((member) {
                    final isMe = member.id == currentUserId;
                    final isMemberOwner = member.id == household.ownerId;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: member.imageUrl?.isNotEmpty == true ? CachedNetworkImageProvider(member.imageUrl!) : null,
                        child: member.imageUrl?.isEmpty != false ? const Icon(Icons.person) : null,
                      ),
                      title: Text('${member.name}${isMe ? ' (You)' : ''}'),
                      subtitle: Text(isMemberOwner ? 'Owner' : 'Member'),
                      trailing: (isOwner && !isMe)
                          ? IconButton(
                              icon: const Icon(Icons.person_remove),
                              onPressed: () async {
                                final confirm = await showConfirmDialog(
                                  context,
                                  title: 'Remove Member',
                                  content: 'Remove ${member.name} from the household?',
                                  confirmLabel: 'Remove',
                                  destructive: true,
                                );
                                if (confirm) {
                                  await ref.read(householdProvider.notifier).removeMember(member.id);
                                }
                              },
                            )
                          : null,
                    );
                  }),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isOwner)
                      FilledButton.icon(
                        onPressed: () => showInviteUserDialog(context),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Invite Member'),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => showJoinHouseholdDialog(context),
                      icon: const Icon(Icons.login),
                      label: const Text('Join Another'),
                    ),
                    if (!isOwner)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: context.colors.error),
                        onPressed: () async {
                          final confirm = await showConfirmDialog(
                            context,
                            title: 'Leave Household',
                            content: 'Are you sure you want to leave this household?',
                            confirmLabel: 'Leave',
                            destructive: true,
                          );
                          if (confirm) {
                            await ref.read(householdProvider.notifier).leaveHousehold();
                          }
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Leave Household'),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
