import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../shared/components/dialog_confirm.dart';
import '../../shared/components/standard_async_builder.dart';
import '../../shared/components/standard_card.dart';
import '../../shared/components/standard_picture.dart';
import '../../shared/models/household.dart';
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

    return StandardAsyncBuilder<Household?>(
      value: householdAsync,
      onRetry: () => ref.invalidate(householdProvider),
      data: (household) {
        if (household == null) {
          return StandardCard(
            title: 'Household',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('You are not currently part of a household.'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => showJoinHouseholdDialog(context, ref),
                  icon: const Icon(Icons.login),
                  label: const Text('Join Household'),
                ),
              ],
            ),
          );
        }

        final isOwner = household.ownerId == currentUserId;

        return StandardCard(
          title: 'Household',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      household.name,
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showRenameHouseholdDialog(context, ref),
                      tooltip: 'Rename Household',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Members:', style: context.textTheme.labelLarge),
              const SizedBox(height: 8),
              if (household.members != null)
                ...household.members!.map((member) {
                  final isMe = member.id == currentUserId;
                  final isMemberOwner = member.id == household.ownerId;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: StandardPicture(
                      imageUrl: member.imageUrl,
                      fallbackText: member.name,
                      size: 40,
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
                    onPressed: () => showJoinHouseholdDialog(context, ref),
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
          ),
        );
      },
    );
  }
}
