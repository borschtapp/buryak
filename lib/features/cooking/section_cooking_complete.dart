import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/util/extensions.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
              'Enjoy your meal!',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
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
              label: const Text('Made it'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: context.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
