import 'package:flutter/material.dart';
import '../util/extensions.dart';

enum LoadingButtonType { filled, elevated, outlined, text }

/// A button that displays a [CircularProgressIndicator] when [isLoading] is true.
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;
  final ButtonStyle? style;
  final LoadingButtonType type;
  final double spinnerSize;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.icon,
    this.style,
    this.type = LoadingButtonType.filled,
    this.spinnerSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final Widget spinner = SizedBox(
      height: spinnerSize,
      width: spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: type == LoadingButtonType.filled ? context.colors.onPrimary : null,
      ),
    );

    final onPressedCallback = isLoading ? null : onPressed;

    if (icon != null) {
      final Widget currentIcon = AnimatedSize(
        duration: const Duration(milliseconds: 150),
        child: isLoading ? spinner : icon!,
      );
      return _buildIconButton(context, currentIcon, onPressedCallback);
    }

    final Widget label = AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: isLoading ? spinner : child,
    );
    return _buildButton(context, label, onPressedCallback);
  }

  Widget _buildButton(BuildContext context, Widget content, VoidCallback? callback) {
    return switch (type) {
      LoadingButtonType.filled => FilledButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
      LoadingButtonType.elevated => ElevatedButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
      LoadingButtonType.outlined => OutlinedButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
      LoadingButtonType.text => TextButton(
        onPressed: callback,
        style: style,
        child: content,
      ),
    };
  }

  Widget _buildIconButton(BuildContext context, Widget currentIcon, VoidCallback? callback) {
    return switch (type) {
      LoadingButtonType.filled => FilledButton.icon(
        onPressed: callback,
        icon: currentIcon,
        label: child,
        style: style,
      ),
      LoadingButtonType.elevated => ElevatedButton.icon(
        onPressed: callback,
        icon: currentIcon,
        label: child,
        style: style,
      ),
      LoadingButtonType.outlined => OutlinedButton.icon(
        onPressed: callback,
        icon: currentIcon,
        label: child,
        style: style,
      ),
      LoadingButtonType.text => TextButton.icon(
        onPressed: callback,
        icon: currentIcon,
        label: child,
        style: style,
      ),
    };
  }
}
