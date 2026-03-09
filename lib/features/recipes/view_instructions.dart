import 'package:flutter/material.dart';
import '../../shared/models/recipe_instruction.dart';
import '../../shared/extensions.dart';

class Instructions extends StatelessWidget {
  final List<RecipeInstruction> instructions;
  const Instructions(this.instructions, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: instructions.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
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
      }).toList(),
    );
  }
}
