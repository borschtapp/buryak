import 'package:flutter/material.dart';

import '../providers/theme.dart';
import '../util/extensions.dart';
import '../util/ui_constants.dart';
import 'content_frame.dart';

class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.appBar,
    this.appBarTitle,
    this.tabActions,
    this.floatingActionButton,
    this.hideBottomNavigationBar = false,
    this.extendBodyBehindAppBar = false,
    this.fallbackRoute = 'home',
  });

  final AppBar? appBar;
  final String? appBarTitle;

  /// Static actions for primary-tab routes (e.g. the tune icon on Feed).
  /// These appear in the logo AppBar without disrupting centering or
  /// triggering the inline TabletAppBar header. Ignored for detail routes
  /// that supply a custom [appBar] or [appBarTitle].
  final List<Widget>? tabActions;

  final bool hideBottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;
  final Widget child;
  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimens) {
        if (dimens.isMobile) {
          return Scaffold(
            body: child,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
            appBar: _buildMobileAppBar(context),
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: hideBottomNavigationBar
                ? null
                : NavigationBar(
                    destinations: destinations,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                  ),
          );
        }

        final hasShellAppBar = appBar == null && appBarTitle == null;

        return Scaffold(
          appBar: hasShellAppBar
              ? AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: ThemeProvider.logo(context),
                  actions: tabActions,
                )
              : null,
          body: Row(
            children: [
              NavigationRail(
                leading: floatingActionButton == null
                    ? null
                    : Column(
                        children: [
                          floatingActionButton!,
                          const SizedBox(height: 12),
                        ],
                      ),
                labelType: dimens.isDesktop ? .none : .all,
                extended: dimens.isDesktop,
                minExtendedWidth: 200,
                destinations: destinations
                    .map(
                      (e) => NavigationRailDestination(icon: e.icon, selectedIcon: e.selectedIcon, label: Text(e.label)),
                    )
                    .toList(),
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
              Expanded(child: hasShellAppBar ? child : SafeArea(child: child)),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildMobileAppBar(BuildContext context) {
    if (appBar != null) return appBar!;

    if (appBarTitle != null) {
      return AppBar(
        leading: BackButton(onPressed: () => context.popOrGoNamed(fallbackRoute)),
        title: Text(appBarTitle!),
      );
    }

    return AppBar(
      centerTitle: true,
      title: ThemeProvider.logo(context),
      actions: tabActions,
    );
  }
}

class TabletAppBar extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;
  final String? appBarTitle;
  final bool scrollable;
  final String fallbackRoute;

  const TabletAppBar({
    super.key,
    required this.child,
    this.appBar,
    this.appBarTitle,
    this.scrollable = true,
    this.fallbackRoute = 'home',
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile || (appBar == null && appBarTitle == null)) {
      return Container(alignment: .topLeft, child: child);
    }

    final title = appBarTitle != null ? Text(appBarTitle!, style: context.textTheme.headlineSmall) : appBar?.title;

    final content = ContentFrame(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: .start,
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              children: [
                appBar?.leading ??
                    (appBar?.automaticallyImplyLeading != false
                        ? BackButton(onPressed: () => context.popOrGoNamed(fallbackRoute))
                        : const SizedBox.shrink()),
                const SizedBox(width: 6),
                ?title,
                const Expanded(child: SizedBox()),
                Row(
                  children: appBar?.actions ?? [],
                ),
              ],
            ),
          ),
          if (scrollable) child else Expanded(child: child),
        ],
      ),
    );

    return Container(
      alignment: .topLeft,
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}
