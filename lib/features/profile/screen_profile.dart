import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/user.dart';
import '../../shared/providers/user.dart';
import 'view_profile_details.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User profile;
    try {
      profile = UserService.getUserModel();
    } catch (e) {
      return const Center(child: Text('User not found. Please log in again.'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileDetails(name: profile.name, email: profile.email, image: profile.image),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit_document),
            title: const Text('Terms of Use'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.pushNamed('terms'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.pushNamed('privacy'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await UserService.logout();
              if (context.mounted) context.goNamed('login');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await UserService.deleteAccount();
      if (context.mounted) context.goNamed('login');
    }
  }
}
