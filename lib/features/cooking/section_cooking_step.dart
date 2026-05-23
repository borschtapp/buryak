import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../shared/models/recipe_instruction.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';

class CookingStepPage extends StatelessWidget {
  const CookingStepPage({super.key, required this.instruction});

  final RecipeInstruction instruction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingLarge,
        vertical: UIConstants.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (instruction.imageUrl case final imageUrl?) ...[
            ClipRRect(
              borderRadius: context.shapeMedium,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: context.colors.surfaceContainerHighest),
                ),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (instruction.title case final title?) ...[
            Text(title, style: context.textTheme.titleLarge),
            const SizedBox(height: 12),
          ],

          // Step text — large and readable for kitchen use
          Text(
            instruction.text,
            style: context.textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
