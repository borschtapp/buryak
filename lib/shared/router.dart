import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'providers/user.dart';
import 'views/root_layout.dart';
import 'widgets/fade_transition_page.dart';
import '../features/privacy_screen.dart';
import '../features/recipes/screen_import_recipe.dart';
import '../features/terms_screen.dart';
import '../features/explore/screen_explore.dart';
import '../features/planner/screen_planner.dart';
import '../features/profile/screen_login.dart';
import '../features/profile/screen_profile.dart';
import '../features/profile/screen_collection.dart';
import '../features/profile/screen_register.dart';
import '../features/saved/screen_saved.dart';
import '../features/recipes/screen_recipes_single.dart';
import '../features/shopping/screen_shopping.dart';
import '../features/profile/screen_settings.dart';

const List<AppDestination> destinations = [
  AppDestination(label: 'Explore', route: '/', icon: Icon(Icons.explore)),
  AppDestination(label: 'Saved', route: '/saved', icon: Icon(Icons.bookmark)),
  AppDestination(label: 'Planner', route: '/planner', icon: Icon(Icons.today)),
  AppDestination(label: 'List', route: '/shopping', icon: Icon(Icons.list)),
  AppDestination(label: 'Profile', route: '/profile', icon: Icon(Icons.person)),
];

class AppDestination {
  const AppDestination({
    required this.route,
    required this.label,
    required this.icon,
    this.child,
  });

  final String route;
  final String label;
  final Icon icon;
  final Widget? child;
}

final router = GoRouter(
  routes: [
    GoRoute(
      name: 'home',
      path: '/',
      redirect: _authGuard,
      pageBuilder: (context, state) => FadeTransitionPage<void>(
        key: state.pageKey,
        child: RootLayout(
          currentIndex: 0,
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              onPressed: () => ExploreScreen.showAddFeedDialog(context),
              child: const Icon(Icons.add),
            ),
          ),
          child: const ExploreScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'recipe',
      path: '/recipe/:rid',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RecipeScreen(recipeId: state.pathParameters['rid']!),
      ),
    ),
    GoRoute(
      name: 'collection',
      path: '/collections/:cid',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          currentIndex: 4,
          hideBottomNavigationBar: true,
          contentScrollable: false,
          appBarTitle: 'Cookbook',
          child: CollectionScreen(collectionId: state.pathParameters['cid']!),
        ),
      ),
    ),
    GoRoute(
      name: 'import',
      path: '/import',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RootLayout(
          currentIndex: 0,
          appBarTitle: 'Import Recipe',
          hideBottomNavigationBar: true,
          child: ImportRecipeScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'saved',
      path: '/saved',
      redirect: _authGuard,
      pageBuilder: (context, state) => FadeTransitionPage<void>(
        key: state.pageKey,
        child: RootLayout(
          currentIndex: 1,
          floatingActionButton: FloatingActionButton(
            onPressed: () => GoRouter.of(context).pushNamed('import'),
            child: const Icon(Icons.add),
          ),
          child: const SavedScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'planner',
      path: '/planner',
      redirect: _authGuard,
      pageBuilder: (context, state) => FadeTransitionPage<void>(
        key: state.pageKey,
        child: RootLayout(
          currentIndex: 2,
          child: PlannerScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'shopping',
      path: '/shopping',
      redirect: _authGuard,
      pageBuilder: (context, state) => FadeTransitionPage<void>(
        key: state.pageKey,
        child: const ShoppingScreen(),
      ),
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      redirect: _authGuard,
      pageBuilder: (context, state) => FadeTransitionPage<void>(
        key: state.pageKey,
        child: RootLayout(
          currentIndex: 4,
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => GoRouter.of(context).pushNamed('settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          contentScrollable: false,
          child: const ProfileScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      redirect: _loginGuard,
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
      redirect: _loginGuard,
    ),
    GoRoute(
      name: 'privacy',
      path: '/privacy-policy',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RootLayout(
          currentIndex: 4,
          appBarTitle: 'Privacy Policy',
          hideBottomNavigationBar: true,
          child: PrivacyPolicyScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'terms',
      path: '/terms-of-use',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RootLayout(
          currentIndex: 4,
          appBarTitle: 'Terms of Use',
          hideBottomNavigationBar: true,
          child: TermsOfUseScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RootLayout(
          currentIndex: 4,
          appBarTitle: 'Settings',
          hideBottomNavigationBar: true,
          contentScrollable: false,
          child: SettingsScreen(),
        ),
      ),
    ),
  ],
);

String? _loginGuard(BuildContext context, GoRouterState state) {
  if (UserService.isLoggedIn()) {
    return '/';
  } else {
    return null; // return "null" to display the intended route without redirecting
  }
}

String? _authGuard(BuildContext context, GoRouterState state) {
  if (!UserService.isLoggedIn()) {
    return '/login';
  } else {
    return null;
  }
}
