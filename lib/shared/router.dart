import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'extensions.dart';
import 'providers/shell.dart';
import 'providers/user.dart';
import 'views/root_layout.dart';
import 'models/recipe.dart';

import '../features/legal/screen_privacy_policy.dart';
import 'widgets/recipes/view_recipe_actions.dart';
import '../features/legal/screen_terms_of_use.dart';
import '../features/explore/screen_explore.dart';
import '../features/planner/screen_planner.dart';
import '../features/profile/screen_forgot_password.dart';
import '../features/profile/screen_login.dart';
import '../features/profile/screen_profile.dart';
import '../features/recipes/screen_collection.dart';
import '../features/profile/screen_register.dart';
import '../features/profile/screen_reset_password.dart';
import '../features/recipes/screen_saved.dart';
import '../features/recipes/screen_recipes_single.dart';
import '../features/shopping/screen_shopping.dart';
import 'route_names.dart';

part 'router.g.dart';

const List<AppDestination> destinations = [
  AppDestination(label: 'Explore', route: '/', name: RouteNames.home, icon: Icon(Icons.explore)),
  AppDestination(label: 'Saved', route: '/saved', name: RouteNames.saved, icon: Icon(Icons.bookmark)),
  AppDestination(label: 'Planner', route: '/planner', name: RouteNames.planner, icon: Icon(Icons.today)),
  AppDestination(label: 'List', route: '/shopping', name: RouteNames.shopping, icon: Icon(Icons.list)),
  AppDestination(label: 'Profile', route: '/profile', name: RouteNames.profile, icon: Icon(Icons.person)),
];

class AppDestination {
  const AppDestination({
    required this.route,
    required this.name,
    required this.label,
    required this.icon,
    this.child,
  });

  final String route;
  final String name;
  final String label;
  final Icon icon;
  final Widget? child;
}

// Navigator keys — _rootKey escapes the shell for full-screen routes.
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Maps every named route to the tab index it should highlight.
const Map<String, int> _tabIndex = {
  RouteNames.home: 0,
  RouteNames.recipe: 0, // Detail of Explore
  RouteNames.saved: 1,
  RouteNames.planner: 2,
  RouteNames.shopping: 3,
  RouteNames.profile: 4,
  RouteNames.collection: 1, // Detail of Saved
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
  const _RouteConfig({
    // ignore: unused_element_parameter
    this.appBarTitle,
    this.hideBottomNav = false,
    this.contentScrollable = true,
    this.extendBodyBehindAppBar = false,
  });
}

const Map<String, _RouteConfig> _routeConfigs = {
  RouteNames.profile: _RouteConfig(contentScrollable: false),
  RouteNames.recipe: _RouteConfig(hideBottomNav: true, contentScrollable: false, extendBodyBehindAppBar: true),
  RouteNames.collection: _RouteConfig(hideBottomNav: true, contentScrollable: false),
};

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
          final tabIdx = _tabIndex[routeName] ?? 0;

          final appBar = _buildShellAppBar(context, state, routeName);

          // FABs are published by screens via shellFabProvider.
          Widget? fab;
          if (routeName == RouteNames.home || routeName == RouteNames.shopping || routeName == RouteNames.saved) {
            fab = Consumer(
              builder: (ctx, ref, _) => ref.watch(shellFabProvider) ?? const SizedBox.shrink(),
            );
          }

          return RootLayout(
            currentIndex: tabIdx,
            appBar: appBar,
            appBarTitle: config?.appBarTitle,
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
            name: RouteNames.home,
            path: '/',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: const ExploreScreen(),
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
            name: RouteNames.profile,
            path: '/profile',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => NoTransitionPage<void>(
              key: state.pageKey,
              child: ProfileScreen(joinCode: state.uri.queryParameters['joinCode']),
            ),
          ),
          // ── Detail routes (rendered inside the shell) ────────────────────
          GoRoute(
            name: RouteNames.recipe,
            path: '/recipe/:rid',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: RecipeScreen(
                recipeId: state.pathParameters['rid']!,
                initialRecipe: state.extra is Recipe ? state.extra as Recipe : null,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            name: RouteNames.collection,
            path: '/collections/:cid',
            redirect: _authGuard(ref),
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: CollectionScreen(collectionId: state.pathParameters['cid']!),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
              },
            ),
          ),
        ],
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
            return '/profile?joinCode=$code';
          } else {
            return '/register?code=$code';
          }
        },
      ),
    ],
  );
}

AppBar? _buildShellAppBar(BuildContext context, GoRouterState state, String? routeName) {
  if (routeName == RouteNames.recipe) {
    final recipeId = state.pathParameters['rid'];
    return AppBar(
      leading: BackButton(onPressed: () => context.popOrGoNamed(RouteNames.home)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.shadow.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
      actions: [
        if (recipeId != null) RecipeActions(recipeId: recipeId),
        const SizedBox(width: 8),
      ],
    );
  }
  if (routeName == RouteNames.collection) {
    final collectionId = state.pathParameters['cid'];
    return AppBar(
      title: Consumer(
        builder: (context, ref, _) {
          final collectionAsync = ref.watch(collectionDetailsProvider(collectionId ?? ''));
          return Text(collectionAsync.whenOrNull(data: (c) => c.name) ?? 'Cookbook');
        },
      ),
      leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.saved)),
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
  return (context, state) {
    if (ref.read(authProvider).isLoggedIn) {
      return '/';
    } else {
      return null;
    }
  };
}

String? Function(BuildContext, GoRouterState) _authGuard(Ref ref) {
  return (context, state) {
    if (!ref.read(authProvider).isLoggedIn) {
      return '/${RouteNames.login}';
    } else {
      return null;
    }
  };
}
