import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/collection.dart';
import '../../util/extensions.dart';

/// Renders a dynamic composite cover for a [Collection].
///
/// Displays up to 3 recipe cover images split dynamically, or a fallback icon
/// if the collection is empty.
class CollectionCover extends StatelessWidget {
  final Collection collection;

  const CollectionCover({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final images = (collection.recipes ?? []).map((r) => r.imageUrl).whereType<String>().take(3).toList();

    if (images.isEmpty) {
      return Container(
        color: context.colors.surfaceContainerHighest,
        child: Icon(Icons.collections, size: 48, color: context.colors.onSurfaceVariant),
      );
    }

    if (images.length == 1) {
      return _coverImage(images[0]);
    }

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: _coverImage(images[0])),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _coverImage(images[1])),
        ],
      );
    }

    // 3 images: left half + right half split into top/bottom
    return Row(
      children: [
        Expanded(child: _coverImage(images[0])),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _coverImage(images[1])),
              const Divider(height: 1, thickness: 1),
              Expanded(child: _coverImage(images[2])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coverImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorWidget: (context, _, _) => ColoredBox(color: context.colors.surfaceContainerHighest),
    );
  }
}
