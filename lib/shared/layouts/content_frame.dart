import 'dart:math';

import 'package:flutter/material.dart';

import '../util/ui_constants.dart';

class ContentFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const ContentFrame({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  /// Horizontal padding that centres content of [UIConstants.defaultMaxWidth] within [width].
  ///
  /// For scroll views that span the full width instead of sitting inside a
  /// [ContentFrame], so their scrollbar and wheel area reach the window edge.
  static double gutter(double width) => max(0, (width - UIConstants.defaultMaxWidth) / 2);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(
                padding: padding!,
                child: child,
              )
            : child,
      ),
    );
  }
}
