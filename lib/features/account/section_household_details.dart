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
import '../../shared/util/ui_constants.dart';
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
            title: context.l10n.householdTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(context.l10n.householdNotMember),
                const SizedBox(height: UIConstants.paddingMedium),
                FilledButton.icon(
                  onPressed: () => showJoinHouseholdDialog(context, ref),
                  icon: const Icon(Icons.login),
                  label: Text(context.l10n.householdJoinHousehold),
                ),
              ],
            ),
          );
        }

        final isOwner = household.ownerId == currentUserId;

        return StandardCard(
          title: context.l10n.householdTitle,
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
                      tooltip: context.l10n.householdRenameHousehold,
                    ),
                ],
              ),
              const SizedBox(height: UIConstants.paddingMedium),
              Text(context.l10n.householdMembersTitle, style: context.textTheme.labelLarge),
              const SizedBox(height: UIConstants.paddingSmall),
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
                    title: Text('${member.name}${isMe ? ' (${context.l10n.householdYou})' : ''}'),
                    subtitle: Text(isMemberOwner ? context.l10n.householdOwnerLabel : context.l10n.householdMemberLabel),
                    trailing: (isOwner && !isMe)
                        ? IconButton(
                            icon: const Icon(Icons.person_remove),
                            onPressed: () async {
                              final confirm = await showConfirmDialog(
                                context,
                                title: context.l10n.householdRemoveMemberTitle,
                                content: context.l10n.householdRemoveMemberContent(member.name),
                                confirmLabel: context.l10n.householdRemoveMemberConfirm,
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
              const SizedBox(height: UIConstants.paddingMedium),
              Wrap(
                spacing: UIConstants.paddingSmall,
                runSpacing: UIConstants.paddingSmall,
                children: [
                  if (isOwner)
                    FilledButton.icon(
                      onPressed: () => showInviteUserDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: Text(context.l10n.householdInviteUser),
                    ),
                  OutlinedButton.icon(
                    onPressed: () => showJoinHouseholdDialog(context, ref),
                    icon: const Icon(Icons.login),
                    label: Text(context.l10n.householdJoinHousehold),
                  ),
                  if (!isOwner)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: context.colors.error),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: context.l10n.householdLeave,
                          content: context.l10n.householdLeaveContent,
                          confirmLabel: context.l10n.householdLeaveConfirm,
                          destructive: true,
                        );
                        if (confirm) {
                          await ref.read(householdProvider.notifier).leaveHousehold();
                        }
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: Text(context.l10n.householdLeave),
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
