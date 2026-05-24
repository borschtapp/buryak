import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

class CookingCompletePage extends StatelessWidget {
  const CookingCompletePage({
    super.key,
    required this.recipe,
    required this.onDone,
  });

  final Recipe recipe;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingLarge,
          vertical: 32,
        ),
        child: Column(
          children: [
            if (recipe.imageUrl case final imageUrl?) ...[
              ClipRRect(
                borderRadius: context.shapeLarge,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    height: 250,
                    color: context.colors.surfaceContainerHighest,
                  ),
                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 32),
            ],

            Text(
              context.l10n.cookingEnjoyMeal,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              recipe.name,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: onDone,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(context.l10n.cookingMadeIt),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: UIConstants.paddingMedium),
                textStyle: context.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
