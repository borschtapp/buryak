import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/theme.dart';
import 'breakpoints.dart';

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

extension IntPluralize on int {
  /// Formats a count with a noun, handling singular/plural forms.
  /// Example: 1.pluralize('serving') → "1 serving"
  ///          2.pluralize('serving') → "2 servings"
  String pluralize(String singular, [String? plural]) => this == 1 ? '$this $singular' : '$this ${plural ?? '${singular}s'}';
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

const _fractionsMap = {
  '¼': 0.25,
  '½': 0.50,
  '¾': 0.75,
  '⅐': 0.1428571428571429,
  '⅑': 0.1111111111111111,
  '⅒': 0.1,
  '⅓': 0.3333333333333333,
  '⅔': 0.6666666666666667,
  '⅕': 0.20,
  '⅖': 0.40,
  '⅗': 0.60,
  '⅘': 0.8,
  '⅙': 0.1666666666666667,
  '⅚': 0.8333333333333333,
  '⅛': 0.125,
  '⅜': 0.375,
  '⅝': 0.625,
  '⅞': 0.875,
};

extension DoubleFormat on double? {
  /// The user-facing "pretty" version (e.g., "½", "2 ½", "0.005", "1.1").
  String get displayAmount {
    final self = this;
    if (self == null) return '';

    final integer = self.truncate();
    final fraction = (self - integer).abs();

    // Try to find a matching fraction symbol
    if (fraction > 0.001) {
      for (final entry in _fractionsMap.entries) {
        if ((entry.value - fraction).abs() < 0.001) {
          return integer == 0 ? entry.key : '$integer ${entry.key}';
        }
      }
    }

    // Fall back to the standard numeric format
    return formatAmount;
  }

  /// The standard numeric version (e.g. "2", "0.5", "1.1"), ideal for input fields or fallback.
  String get formatAmount {
    final self = this;
    if (self == null) return '';

    // Maintain high precision for very small numbers
    if (self < 0.01) return self.toString();

    // Show as integer if no decimal part
    if (self == self.truncateToDouble()) return self.truncate().toString();

    // Otherwise, round to at most 2 decimal places
    return ((self * 100).round() / 100).toString();
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
