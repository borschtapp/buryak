import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../util/extensions.dart';

/// A structural wrapper for bottom sheets that provides a standard header,
/// consistent padding, and handles keyboard safety.
class StandardBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final bool showCloseButton;
  final bool showDragHandle;

  const StandardBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.padding,
    this.showCloseButton = true,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (actions != null) ...actions!,
                if (showCloseButton)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                    tooltip: 'Close',
                  ),
              ],
            ),
            const Divider(height: 32),
            child,
          ],
        ),
      ),
    );
  }
}
