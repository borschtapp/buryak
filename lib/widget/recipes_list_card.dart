import 'package:flutter/material.dart';

import '../model/recipe.dart';

class RecipeCard extends StatefulWidget {
  final String recipeId;
  final Recipe recipe;
  const RecipeCard(this.recipeId, this.recipe, {super.key});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            fit: StackFit.passthrough,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Hero(
                  tag: widget.recipeId,
                  child: Image(
                    height: 300,
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.recipe.image != null ? widget.recipe.image!.last.url! : 'https://i.imgur.com/IRAxUoq.jpg'),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      saved = !saved;
                    });
                  },
                  child: Icon(
                    saved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.recipe.getCombinedAuthor() ?? '',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              // Spacer(),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 4),
                    Text(widget.recipe.totalTime == null ? 'n/a' : '${widget.recipe.totalTime!}m'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
