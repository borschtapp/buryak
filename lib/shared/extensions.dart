import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'providers/theme.dart';
import 'util/breakpoints.dart';

/// Provides convenient access to theme, typography, breakpoints, and navigation.
/// Breakpoint checks (isTablet, isDesktop, isMobile) are based on device width.
extension TypographyUtils on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colors => theme.colorScheme;

  BorderRadius get shapeExtraSmall => ThemeProvider.shapeExtraSmall;

  BorderRadius get shapeSmall => ThemeProvider.shapeSmall;

  BorderRadius get shapeMedium => ThemeProvider.shapeMedium;

  BorderRadius get shapeLarge => ThemeProvider.shapeLarge;

  BorderRadius get shapeExtraLarge => ThemeProvider.shapeExtraLarge;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  bool get isTablet => MediaQuery.widthOf(this) > AppBreakpoints.tablet;

  bool get isDesktop => MediaQuery.widthOf(this) > AppBreakpoints.desktop;

  bool get isMobile => !isTablet && !isDesktop;

  void popOrGo(String location) => GoRouter.of(this).canPop() ? pop() : go(location);

  void popOrGoNamed(String route) => GoRouter.of(this).canPop() ? pop() : goNamed(route);
}

/// Provides responsive breakpoints based on available widget space.
/// Breakpoint checks are based on the widget's allocated width, not device width.
extension BreakpointUtils on BoxConstraints {
  bool get isTablet => maxWidth > AppBreakpoints.tablet;

  bool get isDesktop => maxWidth > AppBreakpoints.desktop;

  bool get isMobile => !isTablet && !isDesktop;
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension SecondsToDuration on int? {
  String toFormattedDuration() {
    if (this == null || this == 0) return 'n/a';
    final duration = Duration(seconds: this!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }
    return '${minutes}m';
  }
}

extension ListToggle<T> on List<T> {
  /// Toggles an item in the list: removes if present, adds if absent.
  List<T> toggled(T item) {
    final list = List<T>.from(this);
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
    return list;
  }
}
