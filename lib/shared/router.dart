import 'package:buryak/shared/providers/theme.dart';
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
import '../features/shopping/screen_shopping.dart';

const _pageKey = ValueKey('_pageKey');
const _scaffoldKey = ValueKey('_scaffoldKey');

const List<NavigationDestination> destinations = [
  NavigationDestination(
    label: 'Recipes',
    route: '/',
    icon: Icon(Icons.menu_book),
  ),
  NavigationDestination(
    label: 'Explore',
    route: '/explore',
    icon: Icon(Icons.explore),
  ),
  NavigationDestination(
    label: 'Planner',
    route: '/planner',
    icon: Icon(Icons.today),
  ),
  NavigationDestination(
    label: 'Shopping',
    route: '/shopping',
    icon: Icon(Icons.storefront),
  ),
  NavigationDestination(
    label: 'Profile',
    route: '/profile',
    icon: Icon(Icons.person),
  ),
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
        key: _pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 0,
          floatingActionButton: FloatingActionButton(
            onPressed: () => GoRouter.of(context).pushNamed('import'),
            child: const Icon(Icons.add),
          ),
          child: const RecipesScreen(),
        ),
      ),
      routes: [
        GoRoute(
          name: 'recipe',
          path: 'recipe/:rid',
          pageBuilder: (context, state) => MaterialPage<void>(
            key: state.pageKey,
            child: RootLayout(
              key: _scaffoldKey,
              currentIndex: 0,
              extendBodyBehindAppBar: true,
              hideBottomNavigationBar: true,
              appBar: AppBar(
                leading: const BackButton(),
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: ThemeProvider.gradient(Colors.black),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
              child: RecipeScreen(recipeId: state.params['rid']!),
            ),
          ),
        ),
        GoRoute(
          name: 'import',
          path: 'import',
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
      ],
    ),

    GoRoute(
      name: 'explore',
      path: '/explore',
      redirect: _authGuard,
      pageBuilder: (context, state) => const MaterialPage<void>(
        key: _pageKey,
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
      pageBuilder: (context, state) => const MaterialPage<void>(
        key: _pageKey,
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
      pageBuilder: (context, state) => const MaterialPage<void>(
        key: _pageKey,
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
      pageBuilder: (context, state) => const MaterialPage<void>(
        key: _pageKey,
        child: RootLayout(
          key: _scaffoldKey,
          currentIndex: 4,
          child: ProfileScreen(),
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
