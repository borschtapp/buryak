import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/recipe_instruction.dart';
import '../../extensions.dart';

class Instructions extends StatelessWidget {
  final List<RecipeInstruction> instructions;
  const Instructions(this.instructions, {super.key});

  @override
  Widget build(BuildContext context) {
    if (instructions.isEmpty) return const SizedBox.shrink();

    final sortedItems = [...instructions]..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final step = sortedItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${index + 1}',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (step.imageUrl != null && step.imageUrl!.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: context.shapeMedium,
                  child: Semantics(
                    label: 'Image for step ${step.order ?? index + 1}',
                    child: CachedNetworkImage(
                      imageUrl: step.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: context.shapeMedium,
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (step.title != null) ...[
                Text(step.title!, style: context.textTheme.titleMedium),
                const SizedBox(height: 4),
              ],
              Text(
                step.text,
                style: context.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
