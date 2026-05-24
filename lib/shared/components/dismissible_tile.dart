import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../util/extensions.dart';
import '../util/ui_constants.dart';

/// A wrapper around [Dismissible] that provides consistent backgrounds and logic
/// for swipe-to-edit and swipe-to-delete actions.
class DismissibleTile extends StatelessWidget {
  final Widget child;
  final String label;
  final Future<bool?> Function()? onConfirmDelete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Color? deleteColor;
  final Color? editColor;
  final Key _key;

  const DismissibleTile({
    required Key key,
    required this.child,
    required this.label,
    this.onConfirmDelete,
    this.onDelete,
    this.onEdit,
    this.deleteColor,
    this.editColor,
  }) : _key = key,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final deleteBackground = Container(
      color: deleteColor ?? context.colors.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingLarge),
      child: Icon(Icons.delete, color: context.colors.onError),
    );

    return Dismissible(
      key: _key,
      direction: onEdit != null ? DismissDirection.horizontal : DismissDirection.endToStart,
      background: onEdit != null
          ? Container(
              color: editColor ?? Colors.orange,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingLarge),
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : deleteBackground,
      secondaryBackground: onEdit != null ? deleteBackground : null,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit?.call();
          return false;
        }
        if (onConfirmDelete != null) {
          return await onConfirmDelete!();
        }
        return true;
      },
      onDismissed: (_) {
        onDelete?.call();
        SemanticsService.sendAnnouncement(
          View.of(context),
          '$label removed',
          TextDirection.ltr,
        );
      },
      child: child,
    );
  }
}
