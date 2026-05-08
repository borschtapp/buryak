import 'package:flutter/material.dart';

import '../util/extensions.dart';
import 'standard_card.dart';

/// A standard section for settings-like screens, grouping related tiles together.
class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final bool showDividers;

  const SettingsSection({
    super.key,
    this.title,
    required this.children,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      title: title,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (showDividers && i < children.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

// Sentinel that distinguishes "trailing not provided" from "trailing: null".
const _defaultTrailing = Object();

/// A standard tile for settings-like screens.
class SettingsTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Object? _trailing;
  final VoidCallback? onTap;
  final Color? foregroundColor;
  final bool isLoading;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    Object? trailing = _defaultTrailing,
    this.onTap,
    this.foregroundColor,
    this.isLoading = false,
  }) : _trailing = trailing;

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (isLoading) {
      effectiveLeading = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final Widget? effectiveTrailing = identical(_trailing, _defaultTrailing)
        ? (onTap != null && !isLoading ? const Icon(Icons.chevron_right, size: 20) : null)
        : _trailing as Widget?;

    return ListTile(
      leading: effectiveLeading != null
          ? IconTheme(
              data: IconThemeData(color: foregroundColor ?? context.colors.onSurfaceVariant),
              child: effectiveLeading,
            )
          : null,
      title: Text(
        title,
        style: TextStyle(color: foregroundColor),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: effectiveTrailing,
      onTap: isLoading ? null : onTap,
    );
  }
}
