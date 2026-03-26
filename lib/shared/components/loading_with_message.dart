import 'package:flutter/material.dart';

import 'loading_indicator.dart';

/// A loading indicator with an optional message displayed beside it.
///
/// Combines [LoadingIndicator] with a text message in a Row layout, wrapped with padding.
/// If no message is provided, only the indicator is shown.
class LoadingWithMessage extends StatelessWidget {
  final String? message;
  final double indicatorSize;
  final double indicatorStrokeWidth;
  final Color? indicatorColor;
  final TextStyle? messageStyle;
  final EdgeInsets padding;

  const LoadingWithMessage({
    super.key,
    this.message,
    this.indicatorSize = 20,
    this.indicatorStrokeWidth = 2,
    this.indicatorColor,
    this.messageStyle,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    return Padding(padding: padding, child: content);
  }

  Widget _buildContent(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return LoadingIndicator(
        size: indicatorSize,
        strokeWidth: indicatorStrokeWidth,
        color: indicatorColor,
      );
    }

    return Row(
      children: [
        LoadingIndicator(
          size: indicatorSize,
          strokeWidth: indicatorStrokeWidth,
          color: indicatorColor,
        ),
        const SizedBox(width: 12),
        Text(
          message!,
          style: messageStyle ?? Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
