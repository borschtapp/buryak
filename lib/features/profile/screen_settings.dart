import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/user.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
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
            if (context.mounted) {
              context.goNamed('login');
            }
          },
        ),
      ],
    );
  }
}
