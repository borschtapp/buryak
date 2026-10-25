import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../layouts/content_frame.dart';
import '../../models/recipe.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import 'recipe_tile.dart';

class RecipesGrid extends HookWidget {
  final List<Recipe> recipes;

  const RecipesGrid(
    this.recipes, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = useState<int?>(null);
    final debounceTimer = useRef<Timer?>(null);

    useEffect(
      () =>
          () => debounceTimer.value?.cancel(),
      [],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = ContentFrame.gutter(constraints.maxWidth);
        final contentWidth = constraints.maxWidth - 2 * gutter;
        final itemWidth = constraints.isMobile ? UIConstants.gridItemWidthMobile : UIConstants.gridItemWidthDesktop;
        final newCount = (contentWidth ~/ itemWidth).clamp(1, UIConstants.gridMaxColumns);
        final effectiveCount = crossAxisCount.value ?? newCount;

        if (newCount != effectiveCount) {
          debounceTimer.value?.cancel();
          debounceTimer.value = Timer(const Duration(milliseconds: 200), () {
            crossAxisCount.value = newCount;
          });
        }

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 5),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: effectiveCount,
            childAspectRatio: constraints.isMobile ? 1.2 : 1.1,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return InkWell(
              borderRadius: context.shapeSmall,
              child: RecipeTile(recipe: recipe),
              onTap: () => context.pushNamed(
                'recipe',
                pathParameters: {'rid': recipe.id},
                extra: recipe,
              ),
            );
          },
        );
      },
    );
  }
}
