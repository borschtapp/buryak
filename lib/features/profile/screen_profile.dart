import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/user.dart';
import 'view_profile_details.dart';
import '../../shared/providers/user.dart';
import '../../shared/views/async_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<User> _profileFuture = UserService.getUserModel();

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<User>(
      future: _profileFuture,
      builder: (context, profile) {
        String? name = profile.name;
        String email = profile.email;
        String? image = profile.image;

        return SingleChildScrollView(
          child: Column(
            children: [
              ProfileDetails(
                name: name,
                email: email,
                image: image,
              ),
              const SizedBox(height: 20),
              ProfileMenuItem(
                icon: const Icon(Icons.edit_document),
                label: "Terms of Use",
                onTap: (context) => context.pushNamed('terms'),
              ),
              ProfileMenuItem(
                icon: const Icon(Icons.privacy_tip),
                label: "Privacy Policy",
                onTap: (context) => context.pushNamed('privacy'),
              ),
              ProfileMenuItem(
                icon: const Icon(Icons.logout),
                label: "Logout",
                onTap: (context) async {
                  await UserService.logout();
                  context.goNamed('login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final Icon icon;
  final String label;
  final void Function(BuildContext) onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              icon,
              const SizedBox(width: 20),
              Text(label),
              const Spacer(),
              const Icon(Icons.arrow_forward)
            ],
          ),
        ),
      ),
    );
  }
}
