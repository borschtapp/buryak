import 'dart:math';

import 'package:flutter/material.dart';

import '../../extensions.dart';

class RecipePlaceholder extends StatelessWidget {
  final double? height;
  final BoxFit fit;

  const RecipePlaceholder({
    super.key,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? (context.isMobile ? min(context.mediaQuery.size.height * 0.4, 400.0) : 500.0);

    return Image.asset(
      'assets/images/recipe_placeholder.png',
      height: effectiveHeight,
      width: double.infinity,
      fit: fit,
    );
  }
}
