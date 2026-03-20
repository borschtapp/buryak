import 'package:buryak/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'notifier_household.dart';

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

    return AlertDialog(
      title: const Text('Invite to Household'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Send an invite directly via email:'),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'friend@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isEmailLoading.value
                ? null
                : () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) return;

                    isEmailLoading.value = true;
                    try {
                      await ref.read(householdProvider.notifier).inviteViaEmail(email);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite sent!')));
                        emailController.clear();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    } finally {
                      if (context.mounted) isEmailLoading.value = false;
                    }
                  },
            icon: isEmailLoading.value
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.email),
            label: const Text('Send Email Invite'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Or generate a link to share via other apps:'),
          const SizedBox(height: 8),
          if (generatedCode.value != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                '${AppConstants.baseUrl}/join?code=${generatedCode.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: 'Join my household on Smetana: ${AppConstants.baseUrl}/join?code=${generatedCode.value}',
                  ),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share Link'),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: isLinkLoading.value
                  ? null
                  : () async {
                      isLinkLoading.value = true;
                      try {
                        final token = await ref.read(householdProvider.notifier).generateInvite();
                        if (context.mounted) {
                          generatedCode.value = token.token; // "token" field contains the code
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } finally {
                        if (context.mounted) isLinkLoading.value = false;
                      }
                    },
              icon: isLinkLoading.value
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.link),
              label: const Text('Generate Share Link'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
