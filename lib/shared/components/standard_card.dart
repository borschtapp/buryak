import 'package:flutter/material.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';

/// A standard card container for grouping related content with an optional header.
class StandardCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const StandardCard({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || actions != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConstants.paddingMedium,
              UIConstants.paddingLarge,
              UIConstants.paddingMedium,
              UIConstants.paddingSmall,
            ),
            child: Row(
              children: [
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        Card(
          margin: margin ??
              const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingMedium,
                vertical: UIConstants.paddingSmall,
              ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(UIConstants.paddingMedium),
            child: child,
          ),
        ),
      ],
    );
  }
}
