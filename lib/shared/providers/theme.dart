import 'package:flutter/material.dart';

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

  CardTheme cardTheme() {
    return CardTheme(
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
    return AppBarTheme(
      elevation: 0,
      backgroundColor: colors.onPrimary,
      foregroundColor: colors.onSurface,
    );
  }

  TabBarTheme tabBarTheme(ColorScheme colors) {
    return TabBarTheme(
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

  BottomAppBarTheme bottomAppBarTheme(ColorScheme colors) {
    return BottomAppBarTheme(
      color: colors.surface,
      elevation: 0,
    );
  }

  BottomNavigationBarThemeData bottomNavigationBarTheme(ColorScheme colors) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.surfaceVariant,
      selectedItemColor: colors.onSurface,
      unselectedItemColor: colors.onSurfaceVariant,
      elevation: 0,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
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

  ThemeData light([Color? targetColor]) {
    final originalTheme = ThemeData.light(useMaterial3: true);
    final colorScheme = originalTheme.colorScheme.copyWith(
      primary: const Color(0xFFB32733),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFFFDAD8),
      onPrimaryContainer: const Color(0xFF410007),
      secondary: const Color(0xFFA23761),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFFFD9E2),
      onSecondaryContainer: const Color(0xFF3E001D),
      tertiary: const Color(0xFF516600),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFD1EE7B),
      onTertiaryContainer: const Color(0xFF161E00),
    );

    return originalTheme.copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarTheme(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
    );
  }

  ThemeData dark([Color? targetColor]) {
    final originalTheme = ThemeData.dark(useMaterial3: true);
    final colorScheme = originalTheme.colorScheme.copyWith(
      primary: const Color(0xFFFFB3B1),
      onPrimary: const Color(0xFF680011),
      primaryContainer: const Color(0xFF90081F),
      onPrimaryContainer: const Color(0xFFFFDAD8),
      secondary: const Color(0xFFFFB1C8),
      onSecondary: const Color(0xFF650032),
      secondaryContainer: const Color(0xFF831E49),
      onSecondaryContainer: const Color(0xFFFFD9E2),
      tertiary: const Color(0xFFB6D263),
      onTertiary: const Color(0xFF283500),
      tertiaryContainer: const Color(0xFF3C4D00),
      onTertiaryContainer: const Color(0xFFD1EE7B),
    );

    return originalTheme.copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarTheme(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.background,
    );
  }
}
