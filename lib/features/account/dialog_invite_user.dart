import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/components/icon_label.dart';
import '../../shared/components/loading_button.dart';
import '../../shared/constants.dart';
import '../../shared/providers/household.dart';
import '../../shared/util/error_extensions.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

Future<void> showInviteUserDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => const DialogInviteUser(),
  );
}

class DialogInviteUser extends HookConsumerWidget {
  const DialogInviteUser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final isEmailLoading = useState(false);
    final isLinkLoading = useState(false);
    final generatedCode = useState<String?>(null);

    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.inviteToHousehold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.inviteSendEmailDescription),
          const SizedBox(height: UIConstants.paddingSmall),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: l10n.inviteEmailAddress,
              hintText: l10n.inviteEmailHint,
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          LoadingButton(
            isLoading: isEmailLoading.value,
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              isEmailLoading.value = true;
              try {
                await ref.read(householdProvider.notifier).inviteViaEmail(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.inviteSent)));
                  emailController.clear();
                }
              } catch (e) {
                ref.handleException(e);
              } finally {
                if (context.mounted) isEmailLoading.value = false;
              }
            },
            child: IconLabel(icon: Icons.email, label: l10n.inviteSendEmailButton, iconSize: 24, spacing: 8),
          ),
          const SizedBox(height: UIConstants.paddingLarge),
          const Divider(),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(l10n.inviteOrGenerateLink),
          const SizedBox(height: UIConstants.paddingSmall),
          if (generatedCode.value != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                '${AppConstants.baseUrl}/join?code=${generatedCode.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            FilledButton.icon(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: l10n.inviteShareText('${AppConstants.baseUrl}/join?code=${generatedCode.value}'),
                  ),
                );
              },
              icon: const Icon(Icons.share),
              label: Text(l10n.inviteShareLink),
            ),
          ] else ...[
            LoadingButton(
              isLoading: isLinkLoading.value,
              onPressed: () async {
                isLinkLoading.value = true;
                try {
                  final token = await ref.read(householdProvider.notifier).generateInvite();
                  if (context.mounted) {
                    generatedCode.value = token.token; // "token" field contains the code
                  }
                } catch (e) {
                  ref.handleException(e);
                } finally {
                  if (context.mounted) isLinkLoading.value = false;
                }
              },
              type: LoadingButtonType.outlined,
              child: IconLabel(icon: Icons.link, label: l10n.inviteGenerateShareLink, iconSize: 24, spacing: 8),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
      ],
    );
  }
}
