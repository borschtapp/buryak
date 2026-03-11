import 'package:flutter/material.dart';
import '../../shared/models/user.dart';
import 'view_profile_details.dart';
import '../../shared/providers/user.dart';

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

    String? name = profile.name;
    String email = profile.email;
    String? image = profile.image;

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileDetails(name: name, email: email, image: image),
        ],
      ),
    );
  }
}
