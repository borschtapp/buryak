import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'view_profile_details.dart';
import '../../shared/widgets/app_version.dart';
import '../../shared/providers/user.dart';
import '../../shared/route_names.dart';
import 'view_household_details.dart';
import 'dialog_join_household.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

class ProfileScreen extends HookConsumerWidget {
  final String? joinCode;
  const ProfileScreen({super.key, this.joinCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      if (joinCode != null && joinCode!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showJoinHouseholdDialog(context, initialCode: joinCode);
        });
      }
      return null;
    }, [joinCode]);

    final userState = ref.watch(authProvider);
    final isDeleting = useState(false);
    if (userState == null) {
      return const Center(child: Text('User not found. Please log in again.'));
    }

    final profile = userState;
    final name = profile.name;
    final email = profile.email;
    final image = profile.imageUrl;
    final errorColor = Theme.of(context).colorScheme.error;

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileDetails(name: name, email: email, image: image),
          const SizedBox(height: 16),
          const ViewHouseholdDetails(),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_document),
            title: const Text('Terms of Use'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.pushNamed(RouteNames.terms),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.pushNamed(RouteNames.privacy),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: isDeleting.value ? null : () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(RouteNames.login);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: isDeleting.value
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(Icons.delete_forever, color: errorColor),
            title: Text(
              isDeleting.value ? 'Deleting Account...' : 'Delete Account',
              style: TextStyle(color: errorColor),
            ),
            onTap: isDeleting.value ? null : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'This will permanently delete your account and all associated data. '
                    'This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: TextButton.styleFrom(foregroundColor: errorColor),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                isDeleting.value = true;
                try {
                  await ref.read(authProvider.notifier).deleteAccount();
                  if (context.mounted) {
                    context.goNamed(RouteNames.login);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                    isDeleting.value = false;
                  }
                }
              }
            },
          ),
          const AppVersionSection(),
        ],
      ),
    );
  }
}
