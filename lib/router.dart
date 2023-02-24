import 'package:buryak/screen/explore.dart';
import 'package:buryak/service/user.dart';
import 'package:flutter/material.dart';
import 'package:buryak/screen/recipe.dart';
import 'package:go_router/go_router.dart';

import 'screen/home.dart';
import 'screen/planner.dart';
import 'screen/profile.dart';
import 'screen/shopping.dart';
import 'screen/login.dart';
import 'screen/register.dart';
import 'widget/scaffold_navigation_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavigationBar(child: child);
      },
      routes: [
        GoRoute(
          name: 'explore',
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeScreen(),
          redirect: _authGuard,
        ),
        GoRoute(
          name: 'planner',
          path: '/planner',
          builder: (context, state) => const PlannerScreen(),
          redirect: _authGuard,
        ),
        GoRoute(
          name: 'shopping',
          path: '/shopping',
          builder: (context, state) => const ShoppingScreen(),
          redirect: _authGuard,
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          redirect: _authGuard,
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: 'recipe',
      path: '/recipe/:recipeId',
      builder: (context, state) => RecipeScreen(recipeId: state.params['recipeId']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      redirect: _loginGuard,
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      name: 'register',
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
      redirect: _loginGuard,
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
