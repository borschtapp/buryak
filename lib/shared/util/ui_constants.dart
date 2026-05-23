class UIConstants {
  /// Standard spacing/padding values.
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingContent = 20.0;
  static const double paddingLarge = 24.0;

  /// Default maximum width for centralized content frames.
  static const double defaultMaxWidth = 1440.0;

  /// Threshold in pixels to trigger pagination when scrolling near the end.
  static const double scrollThreshold = 300.0;

  /// Maximum height of the recipe hero image on mobile.
  static const double recipeMaxImageHeight = 400.0;

  /// Maximum height of the recipe hero image on desktop.
  static const double recipeMaxImageHeightDesktop = 500.0;

  /// Default item width for recipe grid on mobile.
  static const double gridItemWidthMobile = 300.0;

  /// Default item width for recipe grid on desktop.
  static const double gridItemWidthDesktop = 350.0;

  /// Item width used for wide-screen grid (>= [AppBreakpoints.wide]).
  static const double gridItemWidthWide = 320.0;

  /// Maximum column count for the wide-screen grid.
  static const int gridMaxColumnsWide = 5;
}
