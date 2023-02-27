import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../shared/providers/user.dart';
import '../../shared/views/async_loader.dart';
import 'view_profile_details.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<RecordModel> _profileFuture = UserService.getUserModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: AsyncLoader<RecordModel>(
          future: _profileFuture,
          builder: (context, profile) {
            String name = profile.data['name'];
            String email = profile.data['email'];
            String avatar = profile.data['avatar'];
            // String avatar = "https://picsum.photos/200/200";

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ProfileDetails(
                    name: name,
                    email: email,
                    avatar: avatar,
                  ),
                  const SizedBox(height: 20),
                  ProfileMenuItem(
                    icon: const Icon(Icons.bookmark),
                    label: "Saved Recipes",
                    onTap: (context) {},
                  ),
                  ProfileMenuItem(
                    icon: const Icon(Icons.star),
                    label: "Super Plan",
                    onTap: (context) {},
                  ),
                  // ProfileMenuItem(
                  //   iconSrc: const Icon(Icons.language),
                  //   title: "Change Language",
                  //   press: () {},
                  // ),
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
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      leading: const SizedBox(),
      // On Android it's false by default
      centerTitle: true,
      title: const Text("Profile"),
      actions: <Widget>[
        TextButton(
          onPressed: () {},
          child: Text(
            "Edit",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(width: 10)
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              icon,
              const SizedBox(width: 20),
              Text(label),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
      ),
    );
  }
}
