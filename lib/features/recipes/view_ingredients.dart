import 'package:flutter/material.dart';

class Ingredients extends StatelessWidget {
  final List<String> ingredients;
  const Ingredients(this.ingredients, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (BuildContext context, int index) {
        return Text(ingredients[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), height: 15);
      },
    );
  }
}
