import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../shared/extensions.dart';

class ProfileAvatar extends StatelessWidget {
  final String? image;
  final String name;

  const ProfileAvatar({super.key, this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    if (image != null && image!.trim().isNotEmpty) {
      return Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.surface, width: 6),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: image!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(
                color: context.colors.primary,
                strokeWidth: 2,
              ),
            ),
            errorWidget: (context, url, error) => _buildPlaceholder(context),
          ),
        ),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final initials = name.trim().isEmpty ? '?' : name.trim().substring(0, 1).toUpperCase();
    return CircleAvatar(
      radius: 70,
      backgroundColor: context.colors.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 90,
          color: context.colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
