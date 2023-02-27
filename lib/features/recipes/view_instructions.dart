import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';

class Instructions extends StatelessWidget {
  final List<HowToSection> instructions;
  const Instructions(this.instructions, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: instructions.length,
      itemBuilder: (BuildContext context, int index) {
        return Text(instructions[index].text!);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), height: 15);
      },
    );
  }
}
