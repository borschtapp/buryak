import 'package:flutter/material.dart';

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
