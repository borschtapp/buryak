import 'package:flutter/material.dart';

import '../../models/recipe_saved_user.dart';
import '../../util/extensions.dart';
import '../standard_picture.dart';

/// Small overlapping avatars of the other household members who liked a recipe.
///
/// Shows at most [maxShown]; the tooltip names everyone.
class LikedByAvatars extends StatelessWidget {
  final List<RecipeSavedUser> users;
  final double size;

  /// Ring around each avatar, separating overlapping ones and lifting them off a photo.
  final Color ringColor;

  static const int maxShown = 3;

  const LikedByAvatars({
    super.key,
    required this.users,
    required this.ringColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    final shown = users.take(maxShown).toList();
    final step = size * 0.65;
    final label = context.l10n.recipeLikedBy(users.map((user) => user.name ?? '?').join(', '));

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: SizedBox(
          width: size + step * (shown.length - 1),
          height: size,
          child: Stack(
            children: [
              for (final (index, user) in shown.indexed)
                Positioned(
                  left: step * index,
                  child: StandardPicture(
                    imageUrl: user.imageUrl,
                    fallbackText: user.name,
                    fallbackIcon: Icons.person,
                    size: size,
                    border: Border.all(color: ringColor, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
