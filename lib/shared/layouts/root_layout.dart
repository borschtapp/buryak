import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart' as router;
import '../util/extensions.dart';
import 'adaptive_navigation.dart';

class RootLayout extends StatelessWidget {
  const RootLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    this.appBar,
    this.appBarTitle,
    this.tabActions,
    this.floatingActionButton,
    this.hideBottomNavigationBar = false,
    this.extendBodyBehindAppBar = false,
    this.contentScrollable = true,
  });

  final Widget child;
  final AppBar? appBar;
  final int currentIndex;
  final String? appBarTitle;
  final List<Widget>? tabActions;
  final bool hideBottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool contentScrollable;
  static const _navigationRailKey = PageStorageKey('navigationRailKey');

  @override
  Widget build(BuildContext context) {
    void onSelected(int index) {
      final destination = router.destinations[index];
      GoRouter.of(context).go(destination.route);
    }

    final fallbackRoute = router.destinations[currentIndex].name;

    // The same key is intentionally shared across all RootLayout instances so
    // Flutter reuses the AdaptiveNavigation widget on every route transition,
    // preserving NavigationRail scroll position and selected state without
    // a rebuild. This works safely because AdaptiveNavigation is stateless.
    return AdaptiveNavigation(
      key: _navigationRailKey,
      appBar: appBar,
      appBarTitle: appBarTitle,
      tabActions: tabActions,
      hideBottomNavigationBar: hideBottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      destinations: router.destinations
          .map((e) => NavigationDestination(icon: e.icon, selectedIcon: e.selectedIcon, label: e.label(context.l10n)))
          .toList(),
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      fallbackRoute: fallbackRoute,
      child: TabletAppBar(
        appBar: appBar,
        appBarTitle: appBarTitle,
        scrollable: contentScrollable,
        fallbackRoute: fallbackRoute,
        child: SelectionArea(
          child: child,
        ),
      ),
    );
  }
}
