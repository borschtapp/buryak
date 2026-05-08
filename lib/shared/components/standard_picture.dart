import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../util/extensions.dart';

enum PictureShape { circle, rounded }

/// A unified image widget with fallback support and standardized styling.
class StandardPicture extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;
  final IconData? fallbackIcon;
  final double size;
  final PictureShape shape;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BoxBorder? border;

  const StandardPicture({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.fallbackIcon,
    this.size = 40,
    this.shape = PictureShape.circle,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? context.colors.primaryContainer;
    final effectiveForegroundColor = foregroundColor ?? context.colors.onPrimaryContainer;

    Widget child;
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: size * 0.5,
            height: size * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(context, effectiveBackgroundColor, effectiveForegroundColor),
      );
    } else {
      child = _buildFallback(context, effectiveBackgroundColor, effectiveForegroundColor);
    }

    final decoration = BoxDecoration(
      shape: shape == PictureShape.circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: shape == PictureShape.rounded ? BorderRadius.circular(borderRadius ?? 12) : null,
      border: border,
      color: effectiveBackgroundColor,
    );

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildFallback(BuildContext context, Color bgColor, Color fgColor) {
    if (fallbackText != null && fallbackText!.trim().isNotEmpty) {
      final initials = fallbackText!.trim().substring(0, 1).toUpperCase();
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.5,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        fallbackIcon ?? Icons.image_outlined,
        color: fgColor.withValues(alpha: 0.7),
        size: size * 0.6,
      ),
    );
  }
}
