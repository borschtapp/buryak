import 'package:flutter/material.dart';

/// A [SliverPersistentHeaderDelegate] that pins a [TabBar] inside a
/// [CustomScrollView], with a divider underneath.
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const StickyTabBarDelegate({required this.tabBar, required this.backgroundColor});

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [tabBar, const Divider(height: 1, thickness: 1)],
      ),
    );
  }

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) => oldDelegate.backgroundColor != backgroundColor || oldDelegate.tabBar != tabBar;
}
