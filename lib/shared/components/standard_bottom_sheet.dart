import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';

/// A structural wrapper for bottom sheets that provides a standard header,
/// consistent padding, and handles keyboard safety.
class StandardBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final bool showCloseButton;

  /// Caps the sheet height at this fraction of the screen height. Leave `null`
  /// to size to content (the default). Use this when the body contains a long
  /// or scrollable region that should be bounded instead of pushing the sheet
  /// off-screen.
  final double? maxHeightFraction;

  /// Wraps [child] in a [Flexible] so a scrollable / expanding body fills the
  /// remaining height instead of overflowing. Only meaningful together with
  /// [maxHeightFraction]. `Flexible` (not `Expanded`) is used so the sheet
  /// still shrink-wraps when the body is short.
  final bool expandChild;

  const StandardBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.padding,
    this.showCloseButton = true,
    this.maxHeightFraction,
    this.expandChild = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...?actions,
            if (showCloseButton)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
                tooltip: context.l10n.close,
              ),
          ],
        ),
        const Divider(height: 32),
        if (expandChild) Flexible(child: child) else child,
      ],
    );

    if (maxHeightFraction != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.heightOf(context) * maxHeightFraction!,
        ),
        child: content,
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.fromLTRB(
              UIConstants.paddingContent,
              UIConstants.paddingContent,
              UIConstants.paddingContent,
              UIConstants.paddingLarge,
            ),
        child: content,
      ),
    );
  }
}
