import 'dart:math';

import 'package:buryak/shared/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class ThemeProvider {
  final pageTransitionsTheme = const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
      TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
      TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
    },
  );

  static BorderRadius get shapeExtraSmall => BorderRadius.circular(4);
  static BorderRadius get shapeSmall => BorderRadius.circular(8);
  static BorderRadius get shapeMedium => BorderRadius.circular(12);
  static BorderRadius get shapeLarge => BorderRadius.circular(16);
  static BorderRadius get shapeExtraLarge => BorderRadius.circular(28);

  static Widget logo(BuildContext context) {
    return SvgPicture.asset(
      "assets/images/logo.svg",
      height: kToolbarHeight + 20,
      colorFilter: ColorFilter.mode(context.colors.onPrimaryContainer, BlendMode.srcIn),
    );
  }

  static Color randomColor() {
    return Color(Random().nextInt(0xffffffff));
  }

  static BoxDecoration gradient(Color color) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0, 1],
        colors: [color, Colors.transparent],
      ),
    );
  }

  CardThemeData cardTheme() {
    return CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: shapeMedium),
      clipBehavior: Clip.antiAlias,
    );
  }

  ListTileThemeData listTileTheme(ColorScheme colors) {
    return ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: shapeMedium),
      selectedColor: colors.secondary,
    );
  }

  AppBarTheme appBarTheme(ColorScheme colors) {
    return const AppBarTheme(elevation: 0);
  }

  TabBarThemeData tabBarTheme(ColorScheme colors) {
    return TabBarThemeData(
      labelColor: colors.secondary,
      unselectedLabelColor: colors.onSurfaceVariant,
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.secondary,
            width: 2,
          ),
        ),
      ),
    );
  }

  NavigationBarThemeData navigationBarTheme(ColorScheme colors) {
    return NavigationBarThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surfaceTint,
      indicatorColor: colors.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colors.onPrimaryContainer);
        }

        return IconThemeData(color: colors.onSurface);
      }),
      elevation: 1,
    );
  }

  NavigationRailThemeData navigationRailTheme(ColorScheme colors) {
    return const NavigationRailThemeData();
  }

  DrawerThemeData drawerTheme(ColorScheme colors) {
    return DrawerThemeData(
      backgroundColor: colors.surface,
    );
  }

  SystemUiOverlayStyle systemUiOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.brightness == Brightness.light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
      systemNavigationBarColor: theme.colorScheme.onTertiary,
    );
  }

  ThemeData themeLight([Color? targetColor]) {
    final originalTheme = ThemeData.light(useMaterial3: true);
    final colorScheme = originalTheme.colorScheme.copyWith(
      primary: const Color(0xFF680019),
      onPrimary: const Color(0xFFFFB3B6),
      primaryContainer: const Color(0xFFFFDADA),
      onPrimaryContainer: const Color(0xFF900828),
      secondary: const Color(0xFF003829),
      onSecondary: const Color(0xFF66DBB2),
      secondaryContainer: const Color(0xFF83F8CD),
      onSecondaryContainer: const Color(0xFF00513C),
      tertiary: const Color(0xFF201A1A),
      onTertiary: const Color(0xFFECE0DF),
      tertiaryContainer: const Color(0xFFDBC9C7),
      onTertiaryContainer: const Color(0xFF635656),
      surface: const Color(0xFFECE0DF),
      onSurface: const Color(0xFF2E2525),
      outline: const Color(0xFF635656),
      surfaceContainerHighest: const Color(0xFFA29494),
      onSurfaceVariant: const Color(0xFF443737),
      error: const Color(0xFF690005),
      onError: const Color(0xFFFFB4AB),
      onErrorContainer: const Color(0xFF93000A),
    );

    return originalTheme.copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      navigationBarTheme: navigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }

  ThemeData themeDark([Color? targetColor]) {
    final originalTheme = ThemeData.dark(useMaterial3: true);
    final colorScheme = originalTheme.colorScheme.copyWith(
      primary: const Color(0xFFFFB3B6),
      onPrimary: const Color(0xFF680019),
      primaryContainer: const Color(0xFF900828),
      onPrimaryContainer: const Color(0xFFFFDADA),
      secondary: const Color(0xFF66DBB2),
      onSecondary: const Color(0xFF003829),
      secondaryContainer: const Color(0xFF00513C),
      onSecondaryContainer: const Color(0xFF83F8CD),
      tertiary: const Color(0xFFECE0DF),
      onTertiary: const Color(0xFF201A1A),
      tertiaryContainer: const Color(0xFF635656),
      onTertiaryContainer: const Color(0xFFDBC9C7),
      surface: const Color(0xFF2E2525),
      onSurface: const Color(0xFFECE0DF),
      outline: const Color(0xFF635656),
      surfaceContainerHighest: const Color(0xFF443737),
      onSurfaceVariant: const Color(0xFFA29494),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      onErrorContainer: const Color(0xFF93000A),
    );

    return originalTheme.copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      navigationBarTheme: navigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}
