import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavigationBar extends StatefulWidget {
  final AppBar? appBar;
  final Widget child;

  const ScaffoldWithNavigationBar({Key? key, required this.child, this.appBar}) : super(key: key);

  @override
  State<ScaffoldWithNavigationBar> createState() => _ScaffoldWithNavigationBarState();
}

class _ScaffoldWithNavigationBarState extends State<ScaffoldWithNavigationBar> {
  static const tabs = [
    NavigationDestinationRoute(
      route: '/explore',
      icon: Icon(Icons.explore),
      label: 'Explore',
    ),
    NavigationDestinationRoute(
      route: '/',
      icon: Icon(Icons.menu_book),
      label: 'Recipes',
    ),
    NavigationDestinationRoute(
      route: '/planner',
      icon: Icon(Icons.today),
      label: 'Planner',
    ),
    NavigationDestinationRoute(
      route: '/shopping',
      icon: Icon(Icons.storefront),
      label: 'Shopping',
    ),
    NavigationDestinationRoute(
      route: '/profile',
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  // getter that computes the current index from the current location, using the helper method below
  int get _currentIndex => _locationToTabIndex(GoRouter.of(context).location);

  int _locationToTabIndex(String location) {
    final index = tabs.indexWhere((t) => t.route == location);
    // if index not found (-1), return 0
    return index < 0 ? 0 : index;
  }

  // callback used to navigate to the desired tab
  void _onItemTapped(BuildContext context, int tabIndex) {
    if (tabIndex != _currentIndex) {
      // go to the initial location of the selected tab (by index)
      context.go(tabs[tabIndex].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        // selectedItemColor: Colors.blue,
        elevation: 0,
        selectedIndex: _currentIndex,
        destinations: tabs,
        onDestinationSelected: (int index) => _onItemTapped(context, index),
      ),
    );
  }
}

class NavigationDestinationRoute extends NavigationDestination {
  const NavigationDestinationRoute({
    super.key,
    required this.route,
    required Widget icon,
    required String label,
  }) : super(icon: icon, label: label);

  final String route;
}
