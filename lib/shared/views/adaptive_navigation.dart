import 'package:flutter/material.dart';

import '../extensions.dart';
import '../providers/theme.dart';
import 'article_content.dart';

class AdaptiveNavigation extends StatelessWidget {
  const AdaptiveNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
    this.appBar,
    this.appBarTitle,
    this.floatingActionButton,
    this.hideBottomNavigationBar = false,
    this.extendBodyBehindAppBar = false,
  });

  final AppBar? appBar;
  final String? appBarTitle;
  final bool hideBottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Widget? floatingActionButton;
  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, dimens) {
      if (dimens.isMobile) {
        return Scaffold(
          body: child,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: buildMobileAppBar(context),
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

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: ThemeProvider.logo(context),
        ),
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
              labelType: dimens.isDesktop ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              extended: dimens.isDesktop,
              minExtendedWidth: 200,
              destinations:
                  destinations.map((e) => NavigationRailDestination(icon: e.icon, label: Text(e.label))).toList(),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
            Expanded(child: child),
          ],
        ),
      );
    });
  }

  AppBar buildMobileAppBar(BuildContext context) {
    if (appBar != null) return appBar!;

    if (appBarTitle != null) {
      return AppBar(
        leading: BackButton(onPressed: () => context.popOrGoNamed('home')),
        title: Text(appBarTitle!),
      );
    }

    return AppBar(
      centerTitle: true,
      title: ThemeProvider.logo(context),
    );
  }
}

class TabletAppBar extends StatelessWidget {
  final Widget child;
  final bool isMobile;
  final AppBar? appBar;
  final String? appBarTitle;

  const TabletAppBar({
    super.key,
    required this.isMobile,
    required this.child,
    this.appBar,
    this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile || (appBar == null && appBarTitle == null)) {
      return Container(alignment: Alignment.topLeft, child: child);
    }

    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: ArticleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  appBar?.leading ?? BackButton(onPressed: () => context.popOrGoNamed('home')),
                  const SizedBox(width: 6),
                  if (appBarTitle != null) Text(appBarTitle!, style: Theme.of(context).textTheme.headlineSmall),
                  const Expanded(child: SizedBox()),
                  Row(
                    children: appBar?.actions ?? [],
                  ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
