import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/account/screen_account.dart';
import '../features/account/screen_forgot_password.dart';
import '../features/account/screen_login.dart';
import '../features/account/screen_register.dart';
import '../features/account/screen_reset_password.dart';
import '../features/cooking/screen_cooking.dart';
import '../features/feed/screen_feed.dart';
import '../features/feed/screen_feeds.dart';
import '../features/legal/screen_privacy_policy.dart';
import '../features/legal/screen_terms_of_use.dart';
import '../features/planner/screen_planner.dart';
import '../features/recipes/screen_collection.dart';
import '../features/recipes/screen_recipe.dart';
import '../features/recipes/screen_saved.dart';
import '../features/shopping/screen_shopping.dart';
import '../l10n/app_localizations.dart';
import 'layouts/root_layout.dart';
import 'models/recipe.dart';
import 'providers/saved.dart';
import 'providers/shell.dart';
import 'providers/user.dart';
import 'route_names.dart';
import 'util/extensions.dart';
import 'util/transitions.dart';

part 'router.g.dart';

final List<AppDestination> destinations = [
  AppDestination(
    label: (l10n) => l10n.navFeed,
    route: '/',
    name: RouteNames.feed,
    icon: const Icon(Icons.explore_outlined),
    selectedIcon: const Icon(Icons.explore),
  ),
  AppDestination(
    label: (l10n) => l10n.navSaved,
    route: '/saved',
    name: RouteNames.saved,
    icon: const Icon(Icons.menu_book_outlined),
    selectedIcon: const Icon(Icons.menu_book),
  ),
  AppDestination(
    label: (l10n) => l10n.navMealPlan,
    route: '/planner',
    name: RouteNames.planner,
    icon: const Icon(Icons.today_outlined),
    selectedIcon: const Icon(Icons.today),
  ),
  AppDestination(
    label: (l10n) => l10n.navShopping,
    route: '/shopping',
    name: RouteNames.shopping,
    icon: const Icon(Icons.shopping_basket_outlined),
    selectedIcon: const Icon(Icons.shopping_basket),
  ),
  AppDestination(
    label: (l10n) => l10n.navAccount,
    route: '/account',
    name: RouteNames.account,
    icon: const Icon(Icons.manage_accounts_outlined),
    selectedIcon: const Icon(Icons.manage_accounts),
  ),
];

class AppDestination {
  const AppDestination({
    required this.route,
    required this.name,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.child,
  });

  final String route;
  final String name;
  final String Function(AppLocalizations) label;
  final Icon icon;
  final Icon selectedIcon;
  final Widget? child;
}

// Navigator keys — _rootKey escapes the shell for full-screen routes.
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Maps every named route to the tab index it should highlight.
/// Note: RouteNames.recipe is intentionally omitted — its tab is resolved
/// dynamically from the route below it in the stack (see [_resolveTabIndex]).
const Map<String, int> _tabIndex = {
  RouteNames.feed: 0,
  RouteNames.saved: 1,
  RouteNames.planner: 2,
  RouteNames.shopping: 3,
  RouteNames.account: 4,
  RouteNames.feeds: 0,
  RouteNames.collection: 1,
  RouteNames.privacy: 4,
  RouteNames.terms: 4,
  RouteNames.login: 4,
  RouteNames.register: 4,
  RouteNames.forgotPassword: 4,
  RouteNames.resetPassword: 4,
};

/// Per-route shell configuration for routes that deviate from defaults.
class _RouteConfig {
  final String? appBarTitle;
  final bool hideBottomNav;
  final bool contentScrollable;
  final bool extendBodyBehindAppBar;

  /// Builds actions for the primary-tab logo AppBar (e.g. tune icon on Feed).
  /// Only applied when no custom [appBar] or [appBarTitle] is in use, so it
  /// never conflicts with detail-route headers.
  final List<Widget> Function(BuildContext)? tabActionsBuilder;

  const _RouteConfig({
    // ignore: unused_element_parameter
    this.appBarTitle,
    this.hideBottomNav = false,
    this.contentScrollable = true,
    this.extendBodyBehindAppBar = false,
    this.tabActionsBuilder,
  });
}

const Map<String, _RouteConfig> _routeConfigs = {
  RouteNames.account: _RouteConfig(contentScrollable: false),
  RouteNames.feed: _RouteConfig(
    tabActionsBuilder: _buildFeedTabActions,
  ),
  RouteNames.feeds: _RouteConfig(hideBottomNav: true, contentScrollable: false),
  RouteNames.recipe: _RouteConfig(hideBottomNav: true, contentScrollable: false, extendBodyBehindAppBar: true),
  RouteNames.collection: _RouteConfig(hideBottomNav: true, contentScrollable: false),
};

List<Widget> _buildFeedTabActions(BuildContext context) => [
  IconButton(
    icon: const Icon(Icons.dashboard_customize),
    tooltip: context.l10n.manageFeedsTitle,
    onPressed: () => context.pushNamed(RouteNames.feeds),
  ),
];

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = _RouterNotifier();
  ref.listen(authProvider, (_, _) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    refreshListenable: notifier,
    routes: [
      // ── Shell: persistent Scaffold + AdaptiveNavigation ───────────────────
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) {
          final routeName = state.topRoute?.name;
          final config = _routeConfigs[routeName];
          final tabIdx = _resolveTabIndex(context, routeName);

          final appBar = _buildShellAppBar(context, state, routeName);
          final tabActions = config?.tabActionsBuilder?.call(context);

          // FABs are published by screens via shellFabProvider.
          Widget? fab;
          if (routeName == RouteNames.feed || routeName == RouteNames.shopping || routeName == RouteNames.saved) {
            fab = Consumer(
              builder: (ctx, ref, _) => ref.watch(shellFabProvider) ?? const SizedBox.shrink(),
            );
          }

          return RootLayout(
            currentIndex: tabIdx,
            appBar: appBar,
            appBarTitle: config?.appBarTitle,
            tabActions: tabActions,
            hideBottomNavigationBar: config?.hideBottomNav ?? false,
            contentScrollable: config?.contentScrollable ?? true,
            extendBodyBehindAppBar: config?.extendBodyBehindAppBar ?? false,
            floatingActionButton: fab,
            child: child,
          );
        },
        routes: [
          // ── Primary tab destinations ─────────────────────────────────────
          GoRoute(
            name: RouteNames.feed,
            path: '/',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const FeedScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.saved,
            path: '/saved',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const SavedScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.planner,
            path: '/planner',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const PlannerScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.shopping,
            path: '/shopping',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ShoppingScreen(),
            ),
          ),
          GoRoute(
            name: RouteNames.account,
            path: '/account',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: AccountScreen(joinCode: state.uri.queryParameters['joinCode']),
            ),
          ),
          // ── Detail routes (rendered inside the shell) ────────────────────
          GoRoute(
            name: RouteNames.recipe,
            path: '/recipes/:rid',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: RecipeScreen(
                recipeId: state.pathParameters['rid']!,
                initialRecipe: state.extra is Recipe ? state.extra as Recipe : null,
                backFallback: _findSourceRouteName(context) ?? RouteNames.feed,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => fadeScaleTransition(animation, child),
            ),
          ),
          GoRoute(
            name: RouteNames.feeds,
            path: '/feeds',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const FeedsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => fadeScaleTransition(animation, child),
            ),
          ),
          GoRoute(
            name: RouteNames.collection,
            path: '/collections/:cid',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: CollectionScreen(collectionId: state.pathParameters['cid']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => fadeScaleTransition(animation, child),
            ),
          ),
        ],
      ),

      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.cooking,
        path: '/cooking/:rid',
        redirect: (context, state) {
          final authRedirect = _authGuard(ref)(context, state);
          if (authRedirect != null) return authRedirect;
          // Deep link without recipe data — redirect to recipe screen
          if (state.extra is! Recipe) {
            return '/recipes/${state.pathParameters['rid']}';
          }
          return null;
        },
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: CookingScreen(recipe: state.extra as Recipe),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => fadeScaleTransition(animation, child),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.privacy,
        path: '/privacy-policy',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.terms,
        path: '/terms-of-use',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const TermsOfUseScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.login,
        path: '/login',
        builder: (context, state) => LoginScreen(
          inviteCode: state.uri.queryParameters['code'],
        ),
        redirect: _loginGuard(ref),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.register,
        path: '/register',
        builder: (context, state) => RegisterScreen(
          inviteCode: state.uri.queryParameters['code'],
        ),
        redirect: _loginGuard(ref),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.forgotPassword,
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
        redirect: _loginGuard(ref),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: RouteNames.resetPassword,
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          token: state.uri.queryParameters['token'] ?? '',
        ),
        redirect: _loginGuard(ref),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        name: 'join',
        path: '/join',
        redirect: (context, state) {
          final code = state.uri.queryParameters['code'];
          if (code == null || code.isEmpty) return '/';
          if (ref.read(authProvider).isLoggedIn) {
            return '/account?joinCode=$code';
          } else {
            return '/register?code=$code';
          }
        },
      ),
      // Catch-all for undefined deep links
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/:route(.*)',
        redirect: (context, state) => '/',
      ),
    ],
  );
}

/// Walks the current GoRouter match list (from top-1 downward) to find the
/// first route that has a known tab index. Used to give pushed detail routes
/// (e.g. recipe) the correct tab highlight and back-navigation fallback.
String? _findSourceRouteName(BuildContext context) {
  try {
    final matches = GoRouter.of(context).routerDelegate.currentConfiguration.matches;
    for (int i = matches.length - 2; i >= 0; i--) {
      final route = matches[i].route;
      if (route is GoRoute && route.name != null && _tabIndex.containsKey(route.name)) {
        return route.name;
      }
    }
  } catch (e, s) {
    assert(() {
      debugPrint('[Router] _findSourceRouteName error: $e\n$s');
      return true;
    }());
  }
  return null;
}

/// Resolves the tab index to highlight for the given route name.
/// For recipe routes this is determined dynamically from the route below in the
/// stack so that the highlighted tab reflects where the user navigated from.
int _resolveTabIndex(BuildContext context, String? routeName) {
  if (routeName == RouteNames.recipe) {
    final source = _findSourceRouteName(context);
    if (source != null) return _tabIndex[source]!;
    return 0;
  }
  return _tabIndex[routeName] ?? 0;
}

PopupMenuItem<String> _opmlMenuItem(IconData icon, String label) => PopupMenuItem<String>(
  enabled: false,
  child: Row(children: [Icon(icon), const SizedBox(width: 12), Text(label)]),
);

AppBar? _buildShellAppBar(BuildContext context, GoRouterState state, String? routeName) {
  if (routeName == RouteNames.recipe) {
    return AppBar(
      toolbarHeight: 0,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
  if (routeName == RouteNames.collection) {
    final collectionId = state.pathParameters['cid'];
    assert(collectionId != null, 'collection route is missing the :cid path parameter');
    if (collectionId == null) return null;
    return AppBar(
      title: Consumer(
        builder: (context, ref, _) {
          final collectionAsync = ref.watch(collectionDetailsProvider(collectionId));
          return Text(collectionAsync.whenOrNull(data: (c) => c.name) ?? context.l10n.cookbookDefaultTitle);
        },
      ),
      leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.saved)),
    );
  }
  if (routeName == RouteNames.feeds) {
    return AppBar(
      title: Text(context.l10n.manageFeedsTitle),
      leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.feed)),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: context.l10n.recipesMoreOptionsTooltip,
          itemBuilder: (_) => [
            _opmlMenuItem(Icons.upload_file, 'Import OPML (Coming soon)'),
            _opmlMenuItem(Icons.download, 'Export OPML (Coming soon)'),
          ],
        ),
      ],
    );
  }
  return null;
}

/// A private [ChangeNotifier] that triggers a re-build of the [GoRouter]
/// whenever the authentication state changes.
class _RouterNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

String? Function(BuildContext, GoRouterState) _loginGuard(Ref ref) {
  return (_, _) {
    if (ref.read(authProvider).isLoggedIn) {
      return '/';
    } else {
      return null;
    }
  };
}

String? Function(BuildContext, GoRouterState) _authGuard(Ref ref) {
  return (context, _) {
    if (!ref.read(authProvider).isLoggedIn) {
      return GoRouter.of(context).namedLocation(RouteNames.login);
    } else {
      return null;
    }
  };
}
