import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';

/// Opens an adaptive modal: on mobile, a modal bottom sheet kept below the status bar
/// and lifted above the on-screen keyboard; on tablet/desktop, a centered modal dialog.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
}) {
  if (!context.isMobile) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: backgroundColor ?? dialogContext.colors.surface,
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.heightOf(dialogContext) * 0.85,
        ),
        clipBehavior: Clip.antiAlias,
        shape: RoundedSuperellipseBorder(borderRadius: dialogContext.shapeLarge),
        child: builder(dialogContext),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: backgroundColor,
    builder: (context) => _KeyboardInset(child: builder(context)),
  );
}

/// Opens [showAppBottomSheet] for a long, scrollable body. On mobile the sheet
/// can be dragged between [minChildSize] and one toolbar below the status bar,
/// and [builder] gets the sheet's scroll controller; in the tablet/desktop dialog
/// it gets `null`.
Future<T?> showAppDraggableSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, ScrollController? scrollController) builder,
  double initialChildSize = 0.6,
  double minChildSize = 0.3,
  bool snap = false,
  List<double>? snapSizes,
}) {
  return showAppBottomSheet<T>(
    context: context,
    builder: (ctx) {
      if (!ctx.isMobile) return builder(ctx, null);
      // Sizes are fractions of the sheet's parent, which already excludes the status
      // bar (`useSafeArea`), so measure it rather than the screen.
      return LayoutBuilder(
        builder: (ctx, constraints) {
          final maxChildSize = (constraints.maxHeight - kToolbarHeight) / constraints.maxHeight;
          return DraggableScrollableSheet(
            initialChildSize: math.min(initialChildSize, maxChildSize),
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            expand: false,
            snap: snap,
            // On a short screen a snap size can fall outside the range; drop it.
            snapSizes: snapSizes?.where((size) => size > minChildSize && size < maxChildSize).toList(),
            builder: builder,
          );
        },
      );
    },
  );
}

/// Pads [child] by the keyboard height. A widget of its own, so the keyboard
/// animation rebuilds only this padding rather than the whole sheet body.
class _KeyboardInset extends StatelessWidget {
  const _KeyboardInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}

/// A structural wrapper for bottom sheets that provides a standard header
/// and consistent padding. Open it with [showAppBottomSheet], which keeps it
/// above the keyboard.
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
  /// remaining height instead of overflowing. Only meaningful when the height is
  /// bounded: by [maxHeightFraction], or by a parent such as a
  /// [DraggableScrollableSheet]. `Flexible` (not `Expanded`) is used so the sheet
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
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            UIConstants.paddingContent,
            UIConstants.paddingContent,
            UIConstants.paddingContent,
            UIConstants.paddingLarge,
          ),
      child: content,
    );
  }
}
