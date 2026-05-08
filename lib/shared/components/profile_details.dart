import 'package:flutter/material.dart';

import '../util/extensions.dart';
import 'standard_picture.dart';

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
            child: StandardPicture(
              imageUrl: image,
              fallbackText: name != null && name!.trim().isNotEmpty ? name! : email!,
              size: 140, // 70 radius * 2
            ),
          ),
          if (name != null && name!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(name!, style: context.textTheme.headlineMedium),
            ),
          if (email != null && email!.trim().isNotEmpty) Text(email!, style: TextStyle(color: context.colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
