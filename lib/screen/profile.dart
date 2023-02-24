import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../constants.dart';
import '../service/user.dart';
import '../widget/async_loader.dart';

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
      backgroundColor: borschtColor,
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

class ProfileAvatar extends StatelessWidget {
  final String avatar, name;
  const ProfileAvatar({super.key, required this.avatar, required this.name});

  @override
  Widget build(BuildContext context) {
    if (avatar != "") {
      return Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 6),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(avatar),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 70,
      backgroundColor: Colors.yellow.shade100,
      child: Text(
        name.substring(0, 1),
        style: TextStyle(fontSize: 90, color: Colors.grey.shade800),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final String name, email, avatar;

  const ProfileDetails({
    Key? key,
    required this.name,
    required this.email,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240, // 240
      child: Stack(
        children: <Widget>[
          ClipPath(
            clipper: CustomShape(),
            child: Container(
              height: 170,
              color: borschtColor,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ProfileAvatar(avatar: avatar, name: name.isNotEmpty ? name : email),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double height = size.height;
    double width = size.width;
    path.lineTo(0, height - 100);
    path.quadraticBezierTo(width / 2, height, width, height - 100);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
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
