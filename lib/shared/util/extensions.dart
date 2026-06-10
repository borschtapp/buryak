import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../models/meal_plan.dart';
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

  String? timeAgo(AppLocalizations l10n, {DateTime? now}) {
    final dt = DateTime.tryParse(this);
    if (dt == null) return null;
    return dt.timeAgo(l10n, now: now);
  }
}

extension RelativeTimeFormatting on DateTime {
  String timeAgo(AppLocalizations l10n, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(this);

    if (diff.isNegative || diff.inSeconds < 60) return l10n.timeAgoJustNow;
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours);
    if (diff.inDays < 7) return l10n.timeAgoDays(diff.inDays);

    return l10n.dateShort(this);
  }
}

extension SecondsToDuration on int? {
  Duration? get asDuration => (this == null || this! <= 0) ? null : Duration(seconds: this!);
}

extension DurationFormatting on Duration {
  String localized(AppLocalizations l10n) {
    final hours = inHours;
    final minutes = inMinutes % 60;

    if (hours > 0 && minutes > 0) return l10n.durationHoursMinutes(hours, minutes);
    if (hours > 0) return l10n.durationHours(hours);
    return l10n.durationMinutes(inMinutes);
  }
}

extension MealTypeL10n on MealType {
  String localized(AppLocalizations l10n) => switch (this) {
    MealType.breakfast => l10n.mealTypeBreakfast,
    MealType.lunch => l10n.mealTypeLunch,
    MealType.dinner => l10n.mealTypeDinner,
    MealType.snack => l10n.mealTypeSnack,
  };
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
    if (fraction > 0.01) {
      for (final entry in _fractionsMap.entries) {
        if ((entry.value - fraction).abs() < 0.01) {
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

    // Limit precision for very small numbers to avoid 15-digit display
    if (self < 0.01) return self.toStringAsFixed(4);

    // Show as integer if no decimal part
    if (self == self.truncateToDouble()) return self.truncate().toString();

    // Otherwise, round to at most 2 decimal places
    return ((self * 100).round() / 100).toString();
  }
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Splits a template string like "Accept {termsLink} and {privacyLink}."
  /// into a list of InlineSpans, replacing named tokens with styled spans.
  List<InlineSpan> buildSpans(
    String template,
    Map<String, InlineSpan> replacements,
  ) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\{(\w+)\}');
    int cursor = 0;

    for (final match in pattern.allMatches(template)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: template.substring(cursor, match.start)));
      }
      final key = match.group(1)!;
      final replacement = replacements[key];
      if (replacement != null) {
        spans.add(replacement);
      }
      cursor = match.end;
    }

    if (cursor < template.length) {
      spans.add(TextSpan(text: template.substring(cursor)));
    }

    return spans;
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
