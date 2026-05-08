import 'package:flutter/material.dart';

enum LoadingButtonType { filled, elevated, outlined, text }

/// A button that displays a [CircularProgressIndicator] when [isLoading] is true.
class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget child;
  final LoadingButtonType type;
  final double spinnerSize;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.child,
    this.type = LoadingButtonType.filled,
    this.spinnerSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final Widget label = AnimatedSize(
      duration: const Duration(milliseconds: 150),
      child: isLoading
          ? SizedBox(
              height: spinnerSize,
              width: spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: type == LoadingButtonType.filled ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            )
          : child,
    );

    return switch (type) {
      LoadingButtonType.filled => FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: label,
      ),
      LoadingButtonType.elevated => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: label,
      ),
      LoadingButtonType.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: label,
      ),
      LoadingButtonType.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: label,
      ),
    };
  }
}
