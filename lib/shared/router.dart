import 'package:buryak/shared/providers/theme.dart';
import 'extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'providers/user.dart';
import 'views/root_layout.dart';
import '../features/privacy_screen.dart';
import '../features/recipes/screen_import_recipe.dart';
import '../features/terms_screen.dart';
import '../features/explore/screen_explore.dart';
import '../features/planner/screen_planner.dart';
import '../features/profile/screen_login.dart';
import '../features/profile/screen_profile.dart';
import '../features/profile/screen_register.dart';
import '../features/recipes/screen_recipes.dart';
import '../features/recipes/screen_recipes_single.dart';
import '../features/recipes/view_recipe_actions.dart';
import '../features/shopping/screen_shopping.dart';
import '../features/profile/screen_settings.dart';

const _scaffoldKey = ValueKey('_scaffoldKey');

const List<NavigationDestination> destinations = [
  NavigationDestination(label: 'Recipes', route: '/', icon: Icon(Icons.menu_book)),
  NavigationDestination(label: 'Explore', route: '/explore', icon: Icon(Icons.explore)),
  NavigationDestination(label: 'Planner', route: '/planner', icon: Icon(Icons.today)),
  NavigationDestination(label: 'Shopping', route: '/shopping', icon: Icon(Icons.storefront)),
  NavigationDestination(label: 'Profile', route: '/profile', icon: Icon(Icons.person)),
];

class NavigationDestination {
  const NavigationDestination({
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
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 0,
          floatingActionButton: FloatingActionButton(
            onPressed: () => GoRouter.of(context).goNamed('import'),
            child: const Icon(Icons.add),
          ),
          child: const RecipesScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'recipe',
      path: '/recipe/:rid',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 0,
          extendBodyBehindAppBar: true,
          hideBottomNavigationBar: true,
          contentScrollable: false,
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.popOrGoNamed('home')),
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(decoration: ThemeProvider.gradient(Colors.black)),
            actions: [
              RecipeActions(recipeId: state.pathParameters['rid']!),
              const SizedBox(width: 8),
            ],
          ),
          child: RecipeScreen(recipeId: state.pathParameters['rid']!),
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
          key: _scaffoldKey,
          currentIndex: 0,
          appBarTitle: 'Import Recipe',
          hideBottomNavigationBar: true,
          child: ImportRecipeScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'explore',
      path: '/explore',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 1,
          child: ExploreScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'planner',
      path: '/planner',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 2,
          child: PlannerScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'shopping',
      path: '/shopping',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 3,
          child: ShoppingScreen(),
        ),
      ),
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      redirect: _authGuard,
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: RootLayout(
          key: _scaffoldKey,
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
          key: _scaffoldKey,
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
          key: _scaffoldKey,
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
          key: _scaffoldKey,
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
