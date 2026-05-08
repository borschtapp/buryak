import 'package:flutter/material.dart';

/// A simple utility widget for a consistent Row with an Icon and a Label.
class IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final double iconSize;
  final TextStyle? textStyle;
  final double spacing;

  const IconLabel({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.iconSize = 14,
    this.textStyle,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: color),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            label,
            style: textStyle?.copyWith(color: color) ?? TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}
