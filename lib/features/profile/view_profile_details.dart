import 'package:flutter/material.dart';

import 'view_profile_avatar.dart';

class ProfileDetails extends StatelessWidget {
  final String? name, email, image;

  const ProfileDetails({
    super.key,
    this.name,
    this.email,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20, left: 30, right: 30),
            child: ProfileAvatar(image: image, name: name != null && name!.trim().isNotEmpty ? name! : email!),
          ),
          if (name != null && name!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(name!, style: Theme.of(context).textTheme.headlineMedium),
            ),
          if (email != null && email!.trim().isNotEmpty)
            Text(email!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
