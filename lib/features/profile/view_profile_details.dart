import 'package:flutter/material.dart';

import 'view_profile_avatar.dart';

class ProfileDetails extends StatelessWidget {
  final String? name;
  final String email, avatar;

  const ProfileDetails({
    Key? key,
    this.name,
    required this.email,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20, left: 30, right: 30),
            child: ProfileAvatar(avatar: avatar, name: name != null && name!.isNotEmpty ? name! : email),
          ),
          if (name != null && name!.isNotEmpty) Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(name!, style: Theme.of(context).textTheme.headlineMedium),
          ),
          Text(email, style: const TextStyle(color: Colors.grey))
        ],
      ),
    );
  }
}
