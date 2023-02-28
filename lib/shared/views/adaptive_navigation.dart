import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../extensions.dart';
import '../providers/theme.dart';

class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) {
        if (dimens.isMobile) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: ThemeProvider.logo(context),
          ),
          body: Row(
            children: [
              NavigationRail(
                labelType: dimens.isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                extended: dimens.isDesktop,
                minExtendedWidth: 180,
                destinations: destinations
                    .map((e) => NavigationRailDestination(icon: e.icon, label: Text(e.label)))
                    .toList(),
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
