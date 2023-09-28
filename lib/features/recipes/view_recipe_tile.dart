import 'package:flutter/material.dart';

import '../../shared/models/recipe.dart';
import '../../shared/extensions.dart';
import '../../shared/repositories/recipe_repository.dart';

class RecipeTile extends StatefulWidget {
  const RecipeTile(this.recipeId, this.recipe, {super.key, required this.isFavorite});

  final int recipeId;
  final Recipe recipe;
  final bool isFavorite;

  @override
  State<RecipeTile> createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  bool saved = false;

  @override
  void initState() {
    super.initState();
    saved = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              ClipRRect(
                borderRadius: context.shapeLarge,
                child: Container(
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(200),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.3],
                    ),
                  ),
                  child: Image.network(
                    widget.recipe.images != null ? widget.recipe.images!.last.url : 'https://i.imgur.com/IRAxUoq.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: InkWell(
                  onTap: () async {
                    if (!saved) {
                      await RecipeRepository.save(widget.recipeId);
                    } else {
                      await RecipeRepository.unsave(widget.recipeId);
                    }

                    setState(() {
                      saved = !saved;
                    });
                  },
                  child: Icon(
                    saved ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.recipe.author != null ? widget.recipe.author!.name! : '',
                      style: Theme.of(context).textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
        )],
      ),
    );
  }
}
