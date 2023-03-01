import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'providers/theme.dart';

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
  bool get isTablet => mediaQuery.size.width > 730;
  bool get isDesktop => mediaQuery.size.width > 1200;
  bool get isMobile => !isTablet && !isDesktop;

  void popOrGo(String location) => GoRouter.of(this).canPop() ? pop() : go(location);
  void popOrGoNamed(String route) => GoRouter.of(this).canPop() ? pop() : goNamed(route);
}

extension BreakpointUtils on BoxConstraints {
  bool get isTablet => maxWidth > 730;
  bool get isDesktop => maxWidth > 1200;
  bool get isMobile => !isTablet && !isDesktop;
}

extension DurationString on String {
  /// Assumes a string (roughly) of the format '\d{1,2}:\d{2}'
  Duration toDuration() {
    final chunks = split(':');
    if (chunks.length == 1) {
      throw Exception('Invalid duration string: $this');
    } else if (chunks.length == 2) {
      return Duration(
        minutes: int.parse(chunks[0].trim()),
        seconds: int.parse(chunks[1].trim()),
      );
    } else if (chunks.length == 3) {
      return Duration(
        hours: int.parse(chunks[0].trim()),
        minutes: int.parse(chunks[1].trim()),
        seconds: int.parse(chunks[2].trim()),
      );
    } else {
      throw Exception('Invalid duration string: $this');
    }
  }
}

extension HumanizedDuration on Duration {
  String toHumanizedString() {
    final seconds = '${inSeconds % 60}'.padLeft(2, '0');
    String minutes = '${inMinutes % 60}';
    if (inHours > 0 || inMinutes == 0) {
      minutes = minutes.padLeft(2, '0');
    }
    String value = '$minutes:$seconds';
    if (inHours > 0) {
      value = '$inHours:$minutes:$seconds';
    }
    return value;
  }
}
