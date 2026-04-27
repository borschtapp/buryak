import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../../shared/models/recipe.dart';
import '../../shared/util/breakpoints.dart';
import '../../shared/util/extensions.dart';
import '../../shared/util/ui_constants.dart';
import 'section_recipe_tile.dart';

class RecipesGrid extends HookWidget {
  final List<Recipe> recipes;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  const RecipesGrid(
    this.recipes, {
    super.key,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = false,
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
        final newCount = constraints.isMobile
            ? max(1, constraints.maxWidth ~/ UIConstants.gridItemWidthMobile)
            : constraints.maxWidth >= AppBreakpoints.wide
            ? min(UIConstants.gridMaxColumnsWide, max(1, constraints.maxWidth ~/ UIConstants.gridItemWidthWide))
            : max(1, constraints.maxWidth ~/ UIConstants.gridItemWidthDesktop);
        final effectiveCount = crossAxisCount.value ?? newCount;

        if (newCount != effectiveCount) {
          debounceTimer.value?.cancel();
          debounceTimer.value = Timer(const Duration(milliseconds: 200), () {
            crossAxisCount.value = newCount;
          });
        }

        return Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (notification) {
                  if (hasMore && !isLoadingMore && notification.metrics.extentAfter < UIConstants.scrollThreshold) {
                    onLoadMore?.call();
                  }
                  return false;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(5),
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
                ),
              ),
            ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
