import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../layouts/content_frame.dart';
import '../../models/recipe.dart';
import '../../route_names.dart';
import '../../util/breakpoints.dart';
import '../../util/extensions.dart';
import '../../util/ui_constants.dart';
import 'recipe_tile.dart';

/// Grid geometry shared by [RecipesGrid] and [SliverRecipesGrid]: tiles centred
/// within the content frame, at most [UIConstants.gridMaxColumns] columns.
({double gutter, int columns, double aspectRatio}) _gridLayout(double width) {
  final gutter = ContentFrame.gutter(width);
  final isMobile = width <= AppBreakpoints.tablet;
  final itemWidth = isMobile ? UIConstants.gridItemWidthMobile : UIConstants.gridItemWidthDesktop;
  return (
    gutter: gutter,
    columns: ((width - 2 * gutter) ~/ itemWidth).clamp(1, UIConstants.gridMaxColumns),
    aspectRatio: isMobile ? 1.2 : 1.1,
  );
}

SliverGridDelegate _gridDelegate(int columns, double aspectRatio) => SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: columns,
  childAspectRatio: aspectRatio,
  mainAxisSpacing: 1,
  crossAxisSpacing: 1,
);

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
        final layout = _gridLayout(constraints.maxWidth);
        final effectiveCount = crossAxisCount.value ?? layout.columns;

        if (layout.columns != effectiveCount) {
          debounceTimer.value?.cancel();
          debounceTimer.value = Timer(const Duration(milliseconds: 200), () {
            crossAxisCount.value = layout.columns;
          });
        }

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: layout.gutter, vertical: 5),
          gridDelegate: _gridDelegate(effectiveCount, layout.aspectRatio),
          itemCount: recipes.length,
          itemBuilder: (context, index) => _RecipeGridCell(recipes[index]),
        );
      },
    );
  }
}

class SliverRecipesGrid extends StatelessWidget {
  final List<Recipe> recipes;

  const SliverRecipesGrid(
    this.recipes, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final layout = _gridLayout(constraints.crossAxisExtent);
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: layout.gutter, vertical: 5),
          sliver: SliverGrid(
            gridDelegate: _gridDelegate(layout.columns, layout.aspectRatio),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _RecipeGridCell(recipes[index]),
              childCount: recipes.length,
            ),
          ),
        );
      },
    );
  }
}

class _RecipeGridCell extends StatelessWidget {
  final Recipe recipe;

  const _RecipeGridCell(this.recipe);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: context.shapeSmall,
      child: RecipeTile(recipe: recipe),
      onTap: () => context.pushNamed(
        RouteNames.recipe,
        pathParameters: {'rid': recipe.id},
        extra: recipe,
      ),
    );
  }
}
