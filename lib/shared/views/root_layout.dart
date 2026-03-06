import 'package:buryak/shared/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_platform/universal_platform.dart';

import '../router.dart' as router;
import 'adaptive_navigation.dart';

class RootLayout extends StatelessWidget {
  const RootLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    this.appBar,
    this.appBarTitle,
    this.floatingActionButton,
    this.hideBottomNavigationBar = false,
    this.extendBodyBehindAppBar = false,
    this.contentScrollable = true,
  });

  final Widget child;
  final AppBar? appBar;
  final int currentIndex;
  final String? appBarTitle;
  final bool hideBottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool contentScrollable;
  static const _switcherKey = ValueKey('switcherKey');
  static const _navigationRailKey = ValueKey('navigationRailKey');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) {
        void onSelected(int index) {
          final destination = router.destinations[index];
          GoRouter.of(context).go(destination.route);
        }

        return AdaptiveNavigation(
          key: _navigationRailKey,
          appBar: appBar,
          appBarTitle: appBarTitle,
          hideBottomNavigationBar: hideBottomNavigationBar,
          floatingActionButton: floatingActionButton,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          destinations: router.destinations.map((e) => NavigationDestination(icon: e.icon, label: e.label)).toList(),
          selectedIndex: currentIndex,
          onDestinationSelected: onSelected,
          child: Column(
            children: [
              Expanded(
                child: _Switcher(
                  key: _switcherKey,
                  child: TabletAppBar(
                    isMobile: dimens.isMobile,
                    appBar: appBar,
                    appBarTitle: appBarTitle,
                    scrollable: contentScrollable,
                    child: SelectionArea(
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Switcher extends StatelessWidget {
  final Widget child;

  const _Switcher({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UniversalPlatform.isDesktop
        ? child
        : AnimatedSwitcher(
            key: key,
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: child,
          );
  }
}
