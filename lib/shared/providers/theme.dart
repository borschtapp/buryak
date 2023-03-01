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
      backgroundColor: colors.secondaryContainer,
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

  NavigationBarThemeData navigationBarTheme(ColorScheme colors) {
    return NavigationBarThemeData(
      backgroundColor: colors.surfaceVariant,
      surfaceTintColor: colors.surfaceTint,
      indicatorColor: colors.primaryContainer,
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

  SystemUiOverlayStyle systemUiOverlayStyle(Brightness platformBrightness) {
    if (platformBrightness == Brightness.dark) {
      return SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: const Color(0xFF2A2730),
      );
    } else {
      return SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: const Color(0xFFE0D8E8),
      );
    }
  }

  ThemeData light([Color? targetColor]) {
    final originalTheme = ThemeData.light(useMaterial3: true);
    final colorScheme = originalTheme.colorScheme.copyWith(
      primary: const Color(0xFF9D3E56),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFFFD9DE),
      onPrimaryContainer: const Color(0xFF3F0016),
      secondary: const Color(0xFFA92F5A),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFFFD9E0),
      onSecondaryContainer: const Color(0xFF3F0019),
      tertiary: const Color(0xFF576500),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFD9ED73),
      onTertiaryContainer: const Color(0xFF191E00),
    );

    return originalTheme.copyWith(
      pageTransitionsTheme: pageTransitionsTheme,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme(colorScheme),
      cardTheme: cardTheme(),
      listTileTheme: listTileTheme(colorScheme),
      bottomAppBarTheme: bottomAppBarTheme(colorScheme),
      bottomNavigationBarTheme: bottomNavigationBarTheme(colorScheme),
      navigationBarTheme: navigationBarTheme(colorScheme),
      navigationRailTheme: navigationRailTheme(colorScheme),
      tabBarTheme: tabBarTheme(colorScheme),
      drawerTheme: drawerTheme(colorScheme),
    );
  }

  ThemeData dark([Color? targetColor]) {
    final originalTheme = ThemeData.dark(useMaterial3: true);
    final colorScheme = originalTheme.colorScheme.copyWith(
      primary: const Color(0xFFFFB2BF),
      onPrimary: const Color(0xFF610E29),
      primaryContainer: const Color(0xFF7F263F),
      onPrimaryContainer: const Color(0xFFFFD9DE),
      secondary: const Color(0xFFFFB1C3),
      onSecondary: const Color(0xFF66002D),
      secondaryContainer: const Color(0xFF891443),
      onSecondaryContainer: const Color(0xFFFFD9E0),
      tertiary: const Color(0xFFBDD05A),
      onTertiary: const Color(0xFF2C3400),
      tertiaryContainer: const Color(0xFF414C00),
      onTertiaryContainer: const Color(0xFFD9ED73),
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
